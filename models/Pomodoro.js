import { z } from "zod";
import { oracledb } from "oracledb";
import { getConnection } from "../config/database.js";
import { logger } from "../utils/logger.js";

//Esquemas de validación
export const pomodoroCreateSchema = z.object({
    type: z.enum(["work", "break", "long_break"]).default("work"),
    duration: z.number().min(1).max(120).default(25),
    notes: z.string().max(500).optional(),
})

export const pomodoroCompleteSchema = z.object({
    actualDuration: z.number().optional(),
    notes: z.string().max(500).optional(),
})

export class Pomodoro {
    constructor(data){
        this.id = data.id;
        this.userId = data.user_id;
        this.sessionType = data.session_type;
        this.durationMinutes = data.duration_minutes;
        this.completed = data.completed === 1;
        this.startedAt = data.started_at
        this.completedAt = data.completed_at;
        this.notes = data.notes;
    }

    //Crear una sesión de Pomodoro
    static async create(userId, sessionDate){
        let connection;
        try {
            const validatedData = pomodoroCreateSchema.parse(sessionDate);
            connection = await getConnection();
            const result = await connection.execute(
                `INSERT INTO pomodoro_sessions (user_id, session_type, duration_minutes, notes)
                 VALUES (:userId, :type, :duration, :notes)
                 RETURNING id INTO :id`,
                {
                    userId,
                    type: validatedData.type,
                    duration: validatedData.duration,
                    notes: validatedData.notes || null,
                    id: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER }
                },
            )

            await connection.commit();

            const sessionId = result.outBinds.id[0];

            logger.info(`Sesion Pomodoro creada: ${validatedData.type} (ID: ${sessionId}, Usuario: ${userId})`);

            return new Pomodoro({
                id: sessionId,
                user_id: userId,
                session_type: validatedData.type,
                duration_minutes: validatedData.duration,
                completed: 0,
                started_at: new Date(),
                completed_at: null,
                notes: validatedData.notes
            });
        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            throw error
        } finally{
            if (connection){
                await connection.close();
            }
        }
    }

    //Buscar por ID y usuario
    static async findByIdAndUser(sessionId, userId){
        let connection;
        try {
            connection = await getConnection();
            const result = await connection.execute(
                `
                SELECT id, user_id, session_type, duration_minutes, completed, started_at, completed_at, notes 
                FROM pomodoro_sessions WHERE id = :sessionId AND user_id = :userId`,
                { sessionId, userId }
            );

            if (result.rows.length === 0) {
                return null;
            }

            const row = result.rows[0];

            return new Pomodoro({
                id: row[0],
                user_id: row[1],
                session_type: row[2],
                duration_minutes: row[3],
                completed: row[4] === 1,
                started_at: row[5],
                completed_at: row[6],
                notes: row[7]
            });
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    //Obtener sesión activa del usuario
    static async getActiveSession(userId) {
        let connection;
        try {
            connection = await getConnection();
            const result = await connection.execute(
                `SELECT id, user_id, session_type, duration_minutes, completed, started_at, completed_at, notes 
                 FROM pomodoro_sessions 
                 WHERE user_id = :userId AND completed = 0 
                 ORDER BY started_at DESC FETCH FIRST 1 ROWS ONLY`,
                { userId }
            );

            if (result.rows.length === 0) {
                return null;
            }

            const row = result.rows[0];

            return new Pomodoro({
                id: row[0],
                user_id: row[1],
                session_type: row[2],
                duration_minutes: row[3],
                completed: row[4],
                started_at: row[5],
                completed_at: row[6],
                notes: row[7]
            });
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    static async getHistory(userId, options={}){
        let connection;
        try{
            const {limit = 50, offset = 0, dateFrom, dateTo} = options;
            connection = await getConnection();
            const query = `
                SELECT id, user_id, session_type, duration_minutes, completed, started_at, completed_at, notes 
                FROM pomodoro_sessions 
                WHERE user_id = :userId
            `;
            const params = { userId, offset, limit };

            if (dateFrom) {
                query += " AND started_at >= TO_DATE(:dateFrom, 'YYYY-MM-DD')";
                params.dateFrom = dateFrom;
            }

            if (dateTo) {
                query += " AND started_at <= TO_DATE(:dateTo, 'YYYY-MM-DD') + 1";
                params.dateTo = dateTo;
            }

            query += " ORDER BY started_at DESC OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY";

            const result = await connection.execute(query, params);

            return result.rows.map(
                (row)=>
                    new Pomodoro({
                        id: row[0],
                        user_id: row[1],
                        session_type: row[2],
                        duration_minutes: row[3],
                        completed: row[4],
                        started_at: row[5],
                        completed_at: row[6],
                        notes: row[7]
                    })
            )
        } finally{
            if(connection){
                await connection.close();
            }
        }
    }

    //Completar una sesión
    async complete(completedData={}) {
        let connection;
        try{
            const validateData = pomodoroCompleteSchema.parse(completedData);
            connection = await getConnection();

            await connection.execute(
                `UPDATE pomodoro_sessions 
                 SET completed = 1, completed_at = CURRENT_TIMESTAMP, notes = :notes 
                 WHERE id = :sessionId`,
                {
                    sessionId: this.id,
                    notes: validateData.notes || this.notes
                }
            );
            await connection.commit();

            this.completed = true;
            this.completedAt = new Date();
            if(validateData.notes) {
                this.notes = validateData.notes;
            }

            logger.info(`Sesión Pomodoro completada: ${this.sessionType} (ID ${this.id})`);

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

    // Calcular minutos transcurridos
    getElapsedMinutes() {
        if (!this.startedAt) {
            return 0;
        }
        const now = new Date();
        return Math.floor((now - new Date(this.startedAt)) / (1000 * 60));
    }

    //Calcular tiempo restante
    getRemainMinutes(){
        const elapsed = this.getElapsedMinutes();
        return Math.max(0, this.durationMinutes - elapsed);
    }

    //Verificar si la sesión está en curso
    isActive() {
        return !this.completed && this.getRemainMinutes() > 0;
    }

    // Serializar a JSON
    toJSON() {
        return {
            id: this.id,
            userId: this.userId,
            type: this.sessionType,
            duration: this.durationMinutes,
            completed: this.completed,
            startedAt: this.startedAt,
            completedAt: this.completedAt,
            notes: this.notes,
            elapsedMinutes: this.getElapsedMinutes(),
            remainMinutes: this.getRemainMinutes(),
            isActive: this.isActive()
        };
    }
}