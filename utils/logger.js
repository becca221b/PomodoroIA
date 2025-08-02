import winston from "winston";
import { mkdirSync } from "fs";

// Create logs directory if it doesn't exist
try {
    mkdirSync("logs", { recursive: true });
} catch (error) {
    // console.error("Error creating logs directory:", error);
    // Directory already exists
}

// Define log format
const logFormat = winston.format.combine(
    winston.format.timestamp(
        {
            format: "YYYY-MM-DD HH:mm:ss"
        }
    ),
    winston.format.errors({ stack: true }),
    winston.format.json()
);

const consoleFormat = winston.format.combine(
    winston.format.colorize(),
    winston.format.timestamp(
        {
            format: "HH:mm:ss"
        }
    ),
    winston.format.printf(({ level, message, timestamp, ...meta }) => {
        let msg = `${timestamp} [${level}] ${message}`;
        if (Object.keys(meta).length > 0) {
            msg += `\n${JSON.stringify(meta)}`;
        }
        return msg;
    })
);

export const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || "info",
    format: logFormat,
    transports: [
        // logs de error a error.log
        new winston.transports.File({
            filename: "logs/error.log",
            level: "error",
            maxsize: 5242880, // 5MB
            maxFiles: 5,
            format: logFormat
        }),
        // All logs to combined.log
        new winston.transports.File({
            filename: "logs/combined.log",
            maxsize: 5242880, // 5MB
            maxFiles: 5,
            format: logFormat
        }),
        
    ]
})

// Si no estamos en producción, añadimos el transporte de consola
if (process.env.NODE_ENV !== "production") {
    logger.add(new winston.transports.Console({
        format: consoleFormat, 
        level: "debug"
    }));
}

//Función para loguear requests HTTP
export function logHttp(req, res, responseTime) {
    logger.info("HTTP Request", {
        method: req.method,
        url: req.url,
        status: res.statusCode,
        responseTime: `${responseTime}ms`,
        userAgent: req.headers["user-agent"],
        userId: req.user?.id || null,
    })
}

// Función para loguear errores de base de datos
export function logDbError(operation, error, context = {}) {
    logger.error("Database Error", {
        operation,
        error: error.message,
        errorCode: error.erroNum || error.code,
        stack: error.stack,
        ...context
    })
}

//Función para loguear eventos de negocio
export function logBusinessEvent(event, data = {}) {
    logger.info("Business Event", {
        event,
        ...data,
        timestamp: new Date().toISOString()
    })
}

