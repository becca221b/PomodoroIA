import { logger } from "../utils/logger.js";

export class SocketService {
  static io = null; // Almacena la instancia de Socket.IO
  // Inicializar Socket.IO
  static initialize(io){
    this.io = io;
    logger.info("Socket.IO inicializado");
  }

  // Emitir evento a usuario específico
  static emitToUser(userId, event, data) {
    if(!this.io) {
      logger.warn("Socket.IO no está inicializado");      
      return;
    }

    this.io.to(userId).emit(event, data);
    logger.debug(`Evento ${event} emitido al usuario ${userId}`, data);
  }

  // Emitir evento a todos los usuarios
  static emitToAll(event, data) {
    if(!this.io){
      logger.warn("Socket.IO no está inicializado");
      return;
    }

    this.io.emit(event, data);
    logger.debug(`Evento ${event} emitido a todos los usuarios`, data);
  }

  // Obtener usuarios conectados
  static getConnectedUsers() {
    if(!this.io) {
      return [];
    }

    const connectedUsers = [];
    const sockets = this.io.sockets.sockets;

    sockets.forEach((socket) => {
      if (socket.userId) {
        connectedUsers.push({
          userId: socket.userId,
          socketId: socket.id,
          connectedAt: socket.connectedAt
        });
      }
    });

    return connectedUsers;
  }
}

// Configurar manejadores de eventos Socket.IO
export function initializeSocketHandlers(io) {
  SocketService.initialize(io);

  io.on("connection", (socket) => {
    logger.info(`Usuario conectado: ${socket.id}`);

    // Unirse a sala por userId
    socket.on("joinRoom", (userId) => {
      socket.userId = userId; // Almacenar userId en el socket
      socket.connectedAt = new Date(); // Almacenar fecha de conexión
      socket.join(`user_${userId}`); // Unirse a sala específica
      logger.info(`Usuario ${userId} se unió a su sala ${userId}`);

      // Notificar conexión
      socket.emit("connected", {
        message: "Conectado al servidor",
        userId: userId,
        timestamp: new Date().toISOString()
      });
    })

    // Manejar inicio de Pomodoro
    socket.on("pomodoro-start", (data) => {
      if(socket.userId){
        SocketService.emitToUser(socket.userId, "pomodoro-started", {
          ...data,
          timestamp: new Date().toISOString()
        });
        logger.info(`Pomodoro iniciado por el usuario ${socket.userId}`);
      }
    })

    // Manejar finalización de Pomodoro
    socket.on("pomodoro-end", (data) => {
      if(socket.userId){
        SocketService.emitToUser(socket.userId, "pomodoro-completed", {
          ...data,
          timestamp: new Date().toISOString()
        });
        logger.info(`Pomodoro finalizado por el usuario ${socket.userId}`);
      }
    })

    // Manejar pausa de Pomodoro
    socket.on("pomodoro-pause", (data) => {
      if(socket.userId){
        SocketService.emitToUser(socket.userId, "pomodoro-paused", {
          ...data,
          timestamp: new Date().toISOString()
        });
        logger.info(`Pomodoro pausado por el usuario ${socket.userId}`);
      }
    })

    // Manejar registro de emoción
    socket.on("emotion-logged", (data) => {
      if(socket.userId){
        SocketService.emitToUser(socket.userId, "emotion-logged", {
          ...data,
          timestamp: new Date().toISOString()
        });
        logger.info(`Emoción registrada por el usuario ${socket.userId}`);
      }
    });

    // Manejar eventos de typing
    socket.on("typing", () => {
      if(socket.userId){
        socket.broadcast.to(`user_${socket.userId}`).emit("user-typing", {
          userId: socket.userId,
          timestamp: new Date().toISOString()
        });
      }
    });

    socket.on("stop-typing", () => {
      if(socket.userId){
        socket.broadcast.to(`user_${socket.userId}`).emit("user-stopped-typing", {
          userId: socket.userId,
          timestamp: new Date().toISOString()
        });
      }
    })

    // Manejar desconexión
    socket.on("disconnect", (reason) => {
      logger.info(`Usuario desconectado: ${socket.id}, razón: ${reason}`);

      if(socket.userId){
        logger
      }
    })

    // Manejar errores
    socket.on("error", (error) => {
      logger.error(`Error en socket ${socket.id}:`, error);
    })
  });

  logger.info("Manejadores de eventos Socket.IO configurados");
}