import { z } from 'zod';
import oracledb from 'oracledb';
import { getConnection } from '../config/database.js';
import { logger } from '../utils/logger.js';

// Esquemas de validación
export const achievementCreateSchema = z.object({
    name: z.string().min(1).max(100),
    description: z.string().max(500),
    category: z.string().max(50),
    points: z.number().min(0).default(0),
    icon: z.string().max(100).optional(),
    requirements: z.record(z.any())
})

export class Achievement{
    constructor(data) {
        this.id = data.id;
        this.name = data.name;
        this.description = data.description;
        this.category = data.category;
        this.points = data.points;
        this.icon = data.icon;
        this.requirements = data.requirements ? JSON.parse(data.requirements) : {};
        this.createdAt = data.created_at;
    }

    // Obtener todos los logros
    static async getAll() {
        let connection;

        try {
            connection = await getConnection();
            const result = await connection.execute(
                `SELECT id, name, description, category, points, icon, requirements, created_at
                 FROM achievements
                 ORDER BY category, points`
            );

            return result.rows.map(
                (row) => new Achievement({
                id: row[0],
                name: row[1],
                description: row[2],
                category: row[3],
                points: row[4],
                icon: row[5],
                requirements: row[6],
                created_at: row[7]
            }));
        } finally {
            if(connection){
                await connection.close();
            }
        }
    }

    // Obtener logros por categoría
    static async getByCategory(category) {
        let connection;

        try {
            connection = await getConnection();

            const result = await connection.execute(
                `SELECT id, name, description, category, points, icon, requirements, created_at
                 FROM achievements
                 WHERE category = :category
                 ORDER BY points`,
                { category }
            );

            return result.rows.map(
                (row) => new Achievement({
                id: row[0],
                name: row[1],
                description: row[2],
                category: row[3],
                points: row[4],
                icon: row[5],
                requirements: row[6],
                created_at: row[7]
            }));
        } finally {
            if(connection){
                await connection.close();
            }
        }
    }

    // Crear un nuevo logro
    static async create(achievementData) {
        let connection
        try {
            const validatedData = achievementCreateSchema.parse(achievementData);

            connection = await getConnection();

            const result = await connection.execute(
                `INSERT INTO achievements (name, description, category, points, icon, requirements)
                 VALUES (:name, :description, :category, :points, :icon, :requirements)
                 RETURNING id INTO :id`,
                {
                    name: validatedData.name,
                    description: validatedData.description,
                    category: validatedData.category,
                    points: validatedData.points,
                    icon: validatedData.icon || null,
                    requirements: JSON.stringify(validatedData.requirements),
                    id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                },
            );

            await connection.commit();

            const achievementId = result.outBinds.id[0];

            logger.info(`Logro creado: ${validatedData.name} (ID: ${achievementId})`);

            return new Achievement({
                id: achievementId,
                name: validatedData.name,
                description: validatedData.description,
                category: validatedData.category,
                points: validatedData.points,
                icon: validatedData.icon || null,
                requirements: JSON.stringify(validatedData.requirements),
                created_at: new Date()
             });
        } catch (error) {
            if(connection) {
                await connection.rollback();
            }
            throw error;
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Serializar para JSON
    toJSON() {
        return {
            id: this.id,
            name: this.name,
            description: this.description,
            category: this.category,
            points: this.points,
            icon: this.icon,
            requirements: this.requirements,
            createdAt: this.createdAt
        };
    }
}

export class UserAchievment{
    constructor(data) {
        this.id = data.id;
        this.userId = data.user_id;
        this.achievementId = data.achievement_id;
        this.earnedAt = data.earned_at;
        this.progress = data.progress;  
    }

    // Otorgar logro a usuario
    static async grant(userId, achievementId, progress = 100) {
        let connection;

        try {
            connection = await getConnection();

            // Verificar si el logro ya fue otorgado
            const existing = await connection.execute(
                `SELECT id FROM user_achievements
                 WHERE user_id = :userId AND achievement_id = :achievementId`,
                { userId, achievementId }
            )

            if (existing.rows.length > 0) {
                throw new Error(`El usuario ${userId} ya tiene el logro ${achievementId}`);
            }

            const result = await connection.execute(
                `INSERT INTO user_achievements (user_id, achievement_id, progress)
                 VALUES (:userId, :achievementId, :progress)
                 RETURNING id INTO :id`,
                {
                    userId,
                    achievementId,
                    progress,
                    id: { type: oracledb.NUMBER, dir: oracledb.BIND_OUT }
                },
            );
            await connection.commit();

            const userAchievementId = result.outBinds.id[0];

            logger.info(`Logro otorgado al usuario ${userId}, Logro: ${achievementId}`);

            return new UserAchievment({
                id: userAchievementId,
                user_id: userId,
                achievement_id: achievementId,
                earned_at: new Date(),
                progress
            });
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

    // Obtener logros de un usuario
    static async getUserAchievements(userId) {
        let connection;

        try {
            connection = await getConnection();

            const result = await connection.execute(
                `SELECT a.id, a.description, a.category, a.points, a.icon, ua.earned_at, ua.progress
                 FROM user_achievements ua
                 JOIN achievements a ON ua.achievement_id = a.id
                 WHERE ua.user_id = :userId
                 ORDER BY ua.earned_at DESC`,
                { userId }
            );

            return result.rows.map((row) => ({
                achievement: new Achievement({
                    id: row[0],
                    name: row[1],
                    description: row[2],
                    category: row[3],
                    points: row[4],
                    icon: row[5],
                    requirements: "{}",
                    created_at: null,
                }),
                earnedAt: row[6],
                progress: row[7]
            
            }));
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }

    // Obtener logros disponibles para un usuario
    static async getAvailableAchievements(userId) {
        let connection;

        try {
            connection = await getConnection();

            const result = await connection.execute(
                `SELECT a.id, a.name, a.category, a.points, a.icon, a.requirements
                    CASE WHEN ua.achievement_id IS NOT NULL THEN 1 ELSE 0 END as earned,
                    ua.earned_at, ua.progress
                 FROM achievements a
                 LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user_id = :userId
                 ORDER BY earned DESC, a.category, a.points`,
                { userId }
            );

            return result.rows.map((row) => ({
                achievement: new Achievement({
                id: row[0],
                name: row[1],
                description: row[2],
                category: row[3],
                points: row[4],
                icon: row[5],
                requirements: row[6],
                created_at: null,
            }),
                earned: row[7] === 1,
                earnedAt: row[8],
                progress: row[9] || 0
            }));
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
    // Serializar para JSON
    toJSON() {
        return {
            id: this.id,
            userId: this.userId,
            achievementId: this.achievementId,
            earnedAt: this.earnedAt,
            progress: this.progress
        };
    }
}
