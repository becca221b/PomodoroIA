import { UserAchievment } from "../models/Achievement.js";
import { UserStats } from "../models/UserStats.js";
import { getConnection } from "../config/database.js";
import { logger } from "../utils/logger.js";

export class AchievementService{
    // Verificar y otorgar logros
    static async checkAchievements(userId){
        let connection;
        const newAchievements = [];

        try {
            connection = await getConnection();

            // Obtener estadísticas actuales del usuario
            const userStats = await UserStats.getByUserId(userId);
           
            // Obtener logros no obtenidos
            const availableResult = await connection.execute(
               `
               SELECT a.id, a.name, a.requirements
               FROM achievements a
               LEFT JOIN user_achievements ua ON a.id = ua.achievement_id AND ua.user = :userId
               WHERE ua.achievement_id IS NULL
               `,
               {userId}
            )

            // Verificar cada logro
            for(const row of availableResult.rows){

            }
            return newAchievements;
        } catch (error) {
            logger.error("Error verificando logros:", error);
            return[];
        } finally {
            if (connection) {
                await connection.close();
            }
        }        
    }

    // Verificar si cumple los requisitos de un logro

    // Calcular progreso de logros
    static async calculateProgress(userId) {
        
       
    }

    // Obtener estadísticas de logros
    static async getStats(userId) {
        let connection;
        try {
            connection = await getConnection();

            // Estadísticas generales
            const statsResult = await connection.execute(`
                SELECT 
                    COUNT(*) AS total_earned,
                    SUM(a.points) as total_points,
                    COUNT(DISTINCT a.category) as categories_completed
                FROM user_achievements ua
                JOIN achievements a ON ua.achievement_id = a.id
                WHERE ua.user_id = :userId
            `, { userId });

            // Total de logros disponibles
            const totalResult = await connection.execute(`
                SELECT COUNT(*) AS total_available,
                        COUNT(DISTINCT category) AS total_categories
                FROM achievements
            `);

            // Logros por categoria
            const categoryResult = await connection.execute(`
                SELECT a.category, COUNT(*) AS earned_count,
                    (SELECT COUNT(*)
                    FROM achievements
                    WHERE category = a.category) AS total_count
                FROM user_achievements ua
                JOIN achievements a ON ua.achievement_id = a.id
                WHERE ua.user_id = :userId
                GROUP BY a.category
            `, { userId });

            // Logros recientes
            const recentResult = await connection.execute(`
                SELECT a.name, a.icon, a.points, ua.earned_at
                FROM user_achievements ua
                JOIN achievements a ON ua.achievement_id = a.id
                WHERE ua.user_id = :userId
                ORDER BY ua.earned_at DESC
                FETCH FIRST 5 ROWS ONLY
            `, { userId });

            const stats = {
                totalEarned: statsResult.rows[0][0] || 0,
                totalAvailable: totalResult.rows[0][0] || 0,
                totalPoints: statsResult.rows[0][1] || 0,
                categoriesCompleted: statsResult.rows[0][2] || 0,
                completionPercentage: totalResult.rows[0][0] > 0 ? 
                    Math.round((statsResult.rows[0][0] || 0 / totalResult.rows[0][0]) * 100) : 0,
            }

            const categoryStats = categoryResult.rows.map(row => ({
                category: row[0],
                earnedCount: row[1],
                totalCount: row[2],
                completionPercentage: Math.round((row[1] / row[2]) * 100)
            }))

            const recentAchievements = recentResult.rows.map(row => ({
                name: row[0],
                icon: row[1],
                points: row[2],
                earnedAt: row[3]
            }));

            return {
                stats,
                categoryStats,
                recentAchievements
            }
            
        } finally {
            if (connection) {
                await connection.close();
            }
        }
    }
    
}
