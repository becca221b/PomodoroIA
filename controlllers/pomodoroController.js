import { Pomodoro } from "../models/Pomodoro.js";
import { UserStats } from "../models/UserStats.js";
import { AchievementService } from "../services/achievementService.js";
import { SocketService } from "../services/SocketService.js";
import { logger } from "../utils/logger.js";

export class PomodoroController {
    // Iniciar nueva sesión
    static async startSession(req, res) {
        try {
            const session = await Pomodoro.create(req.user.id, req.body);

            // Emitir evento via Socket.IO
            SocketService.emitToUser(req.user.id,"pomodoro-started",{
                sessionId: session.id,
                duration: session.durationMinutes,
                type: session.type,
                startedAt: session.startedAt
            })

            req.status(201).json({
                success: true,
                message: 'Pomodoro session started successfully',
                session: session.toJSON()
            });
        } catch (error) {
            logger.error('Error starting pomodoro session:', error);

            if(error.name === 'ZodError') {
                return res.status(400).json({ 
                    success: false,
                    error: "Datos de entrada inválidos",
                    details: error.errors
                });
            }
            res.status(500).json({
                success: false,
                message: 'Error interno del servidor' });
        }
    }

    // Completar sesión
    static async completeSession(req, res) {
        try {
            const {sessionId, ...completeData} = req.body;
            const session = await Pomodoro.findByIdAndUser(sessionId, req.user.id);

            if(!session) {
                return res.status(404).json({
                    success: false,
                    message: 'Pomodoro session not found'
                });
            }

            if(session.completed) {
                return res.status(400).json({
                    success: false,
                    message: 'Pomodoro session already completed'
                });
            }

            // Completar sesión
            await session.complete(completeData);

            // Actualizar estadísticas del usuario si es sesión de trabajo
            if(session.type === 'work') {
                await UserStats.updateAfterPomodoro(req.user.id, session.sessionType, session.durationMinutes);
            }

            // Verificar logros
            const newAchievements = await AchievementService.checkAchievements(req.user.id);

            // Emitir evento via Socket.IO
            SocketService.emitToUser(req.user.id, "pomodoro-completed", {
                sessionId: session.id,
                type: session.sessionType,
                completedAt: session.completedAt,
                newAchievements
            })

            res.json({
                success: true,
                message: 'Pomodoro session completed successfully',
                session: session.toJSON(),
                newAchievements
            });
        } catch (error) {
            logger.error('Error completing pomodoro session:', error);

            if(error.name === 'ZodError') {
                return res.status(400).json({ 
                    success: false,
                    error: "Datos de entrada inválidos",
                    details: error.errors
                });
            }

            res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    }

    // Obtener sesión activa
    static async getActiveSession(req, res) {
        try {
            const activeSession = await Pomodoro.getActiveSession(req.user.id);

            res.json({
                success: true,
                activeSession: activeSession ? activeSession.toJSON() : null
            });
        } catch (error) {
            logger.error('Error al obtener sesión activa', error);
            res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    }

    // Obtener historial de sesiones
    static async getHistory(req, res) {
        try {
            const options = {
                limit: Number.parseInt(req.query.limit) || 50,
                offset: Number.parseInt(req.query.offset) || 0,
                dateFrom: req.query.dateFrom,
                dateTo: req.query.dateTo,
            };

            const sessions = await Pomodoro.getHistory(req.user.id, options);

            res.json({
                success: true,
                sessions: sessions.map(session => session.toJSON()),
                pagination: {
                    limit: options.limit,
                    offset: options.offset,
                    total: sessions.length
                }
            })
        } catch (error) {
            logger.error('Error al obtener historial de sesiones', error);
            res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    }

    // Obtener estadísticas
    static async getStats(req, res) {
        try {
            const period = req.query.period || "week";
            const stats = await UserStats.getStats(req.user.id, period);

            res.json({
                success: true,
                stats: stats
            });
        } catch (error) {
            logger.error('Error al obtener estadísticas', error);
            res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    }

    // Cancelar sesión activa
    static async cancelActiveSession(req, res) {
        try {
            const activeSession = await Pomodoro.getActiveSession(req.user.id);

            if(!activeSession) {
                return res.status(404).json({
                    success: false,
                    message: 'No active pomodoro session found'
                });
            }

            // Marcar como completada pero sin actualizar estadísticas
            await activeSession.complete({
                notes: 'Session cancelled by user',
            })

            // Emitir evento via Socket.IO
            SocketService.emitToUser(req.user.id, "pomodoro-cancelled", {
                sessionId: activeSession.id,
                type: activeSession.sessionType,
                cancelledAt: new Date().toISOString()
            });

            res.json({
                success: true,
                message: 'Active pomodoro session cancelled successfully',
                session: activeSession.toJSON()
            });
        } catch (error) {
            logger.error('Error cancelling active pomodoro session:', error);
            res.status(500).json({
                success: false,
                message: 'Error interno del servidor'
            });
        }
    }

}