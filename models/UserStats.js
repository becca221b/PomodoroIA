import { getConnection } from "../config/database.js";
import { logger } from "../utils/logger.js";

export class UserStats {
    constructor(data) {
        this.id = data.id;
        this.userId = data.user_id;
        this.totalPomodoros = data.total_pomodoros;
        this.totalFocusTime = data.total_focus_time;
        this.currentStreak = data.current_streak;
        this.longestStreak = data.longest_streak;
        this.totalPoints = data.total_points;
        this.levelNumber = data.level_number;
        this.updatedAt = data.updated_at;
    }

    // Obtener estadísticas del usuario
    static async getByUserId(userId) {
        let connection;

        try {
            connection = await getConnection();

            const result = await connection.execute(
                `SELECT id, user_id, total_pomodoros, total_focus_time, current_streak, 
                longest_streak, total_points, level_number, updated_at
                FROM user_stats 
                WHERE user_id = :userId`,
                { userId },
            )

            if(result.rows.length === 0) {
                //Crear estadísticas si no existen
                return await UserStats.create(userId);
            }

            const row = result.rows[0];
            return new UserStats({
                id: row[0],
                user_id: row[1],
                total_pomodoros: row[2],
                total_focus_time: row[3],
                current_streak: row[4],
                longest_streak: row[5],
                total_points: row[6],
                level_number: row[7],
                updated_at: row[8]
            });
        } finally {
            if (connection) {
                await connection.close();
            }    
        }
    }

    static async create(userId) {
        let connection

        try {
            connection = await getConnection();
            
            await connection.execute(
                `INSERT INTO user_stats (user_id, total_pomodoros, total_focus_time, current_streak, 
                longest_streak, total_points, level_number, updated_at) 
                VALUES (:userId, 0, 0, 0, 0, 0, 1, CURRENT_TIMESTAMP)`,
                { userId }
            );

            await connection.commit();

            logger.info(`User stats created for user ${userId}`);

            return new UserStats({
                id: null, // ID will be auto-generated
                user_id: userId,
                total_pomodoros: 0,
                total_focus_time: 0,
                current_streak: 0,
                longest_streak: 0,
                total_points: 0,
                level_number: 1,
                updated_at: new Date()
            });

        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            throw error
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Actualizar después de completar un Pomodoro
    static async updateAfterPomodoro(userId, sessionType = "work", durationMinutes = 25) {
        let connection;

        try {
            connection = await getConnection();

            //Solo actualizar estadísticas para sesiones de trabajo
            if(sessionType === "work"){
                await connection.execute(
                    `UPDATE user_stats 
                    SET total_pomodoros = total_pomodoros + 1, 
                        total_focus_time = total_focus_time + :duration, 
                        total_points = total_points + 10, 
                        updated_at = CURRENT_TIMESTAMP 
                    WHERE user_id = :userId`,
                    { userId, duration }
                )

                //Actualizar racha
                await UserStats.updateStreak(connection, userId);

                //Actualizar nivel
                await UserStats.updateLevel(connection, userId);
            }

            await connection.commit();

            logger.info(`User stats updated for user ${userId} after completing a Pomodoro`);

        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            throw error;
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Actualizar racha de trabajo
    static async updateStreak(connection, userId) {
        //Verificar si completó al menos un Pomodoro ayer
        const yesterdayResult = await connection.execute(
            `SELECT COUNT(*) 
            FROM pomodoro_sessions
            WHERE user_id = :userId 
                AND session_type = 'work'
                AND completed = 1 
                AND started_at >= TRUNC(SYSDATE) - 1
                AND started_at < TRUNC(SYSDATE)`,
            { userId }
        );

        const completedYesterday = yesterdayResult.rows[0][0] > 0;

        if(completedYesterday){
            //Continuar racha
            await connection.execute(
                `UPDATE user_stats 
                SET current_streak = current_streak + 1, 
                    longest_streak = GREATEST(longest_streak, current_streak + 1),
                WHERE user_id = :userId`,
                { userId }
            );
        }else{
            //Verificar si es el primer pomodoro de hoy
            const todayResult = await connection.execute(
                `SELECT COUNT(*) 
                FROM pomodoro_sessions
                WHERE user_id = :userId 
                    AND session_type = 'work'
                    AND completed = 1 
                    AND started_at >= TRUNC(SYSDATE)`,
                { userId }
            );

            if(todayResult.rows[0][0] === 1){
                //Primer pomodoro de hoy, reiniciar racha
                await connection.execute(
                    `UPDATE user_stats 
                    SET current_streak = 1,
                        longest_streak = GREATEST(longest_streak, 1),
                    WHERE user_id = :userId`,
                    { userId }
                )
            }
        }
    }

    // Actualizar nivel basado en puntos
    static async updateLevel(connection, userId) {
        const result = await connection.execute(
            `SELECT total_points 
            FROM user_stats 
            WHERE user_id = :userId`,
            { userId }
        );

        if (result.rows.length > 0){
            const totalPoints = result.rows[0][0];
            const newLevel = Math.floor(totalPoints / 100) + 1; // Cada 100 puntos sube un nivel

            await connection.execute(
                `UPDATE user_stats 
                SET level_number = :newLevel 
                WHERE user_id = :userId`,
                { newLevel, userId }
            );
        }
    }

    // Obtener estadísticas con período
    static async getStats(userId, period = "week"){
        let connection;

        try {
            connection = await getConnection();

            //Obtener estadísticas generales
            const generalStats = await UserStats.getByUserId(userId);

            let periodCondition = "";
            switch (period) {
                case "day":
                    periodCondition = `AND started_at >= TRUNC(SYSDATE)`;
                    break;
                case "week":
                    periodCondition = `AND started_at >= TRUNC(SYSDATE, 'IW')`;
                    break;
                case "month":
                    periodCondition = `AND started_at >= TRUNC(SYSDATE, 'MM')`;
                    break;
                case "year":
                    periodCondition = `AND started_at >= TRUNC(SYSDATE, 'YYYY')`;
                    break;
            }

            //Obtener estadísticas del período
            const periodResult = await connection.execute(
                `SELECT 
                    COUNT(CASE WHEN completed = 1 THEN 1 END) AS completed_sessions,
                    SUM(CASE WHEN completed = 1 THEN duration_minutes ELSE null END) AS avg_duration,
                    AVG(CASE WHEN completed = 1 THEN duration_minutes ELSE null END) AS avg_duration
                 FROM pomodoro_sessions 
                 WHERE user_id = :userId 
                 ${periodCondition}`,
                { userId }
            )

            const periodStats = {
                completedSessions: periodResult.rows[0][0] || 0,
                totalDuration: periodResult.rows[0][1] || 0,
                avgDuration: Math.round(periodResult.rows[0][2] || 0)
            }

            return {
                general: generalStats.toJSON(),
                period: {
                    type: period,
                    stats: periodStats
                }
            };
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Actualizar nivel
    async updateLevel() {
        let connection;

        try {
            connection = await getConnection();

            //Actualizar nivel
            await connection.execute(
                `UPDATE user_stats 
                 SET level_number = :newLevel,
                    updated_at = CURRENT_TIMESTAMP 
                 WHERE user_id = :userId`,
                { newLevel, userId: this.userId }
            );

            await connection.commit();

            this.levelNumber = newLevel;
            this.updatedAt = new Date();

            logger.info(`User level updated for user ${this.userId} to level ${newLevel}`);

            return this;
        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            throw error;
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Serializar a JSON
    toJSON() {
        return{
            id: this.id,
            userId: this.userId,
            totalPomodoros: this.totalPomodoros,
            totalFocusTime: this.totalFocusTime,
            currentStreak: this.currentStreak,
            longestStreak: this.longestStreak,
            totalPoints: this.totalPoints,
            level: this.levelNumber,
            updatedAt: this.updatedAt
        }
    }
}