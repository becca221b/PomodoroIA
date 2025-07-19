const mongoose = require('mongoose');

const pomodoroSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
        type: {
            type: String,
            enum: ['work', 'short-break', 'long-break'],
            required: true
        },
        plannedDuration: {
            type: Number, // Duration in minutes
            required: true
        },
        actualDuration: {
            type: Number, // Duration in minutes
            default: 0
        },
        completed: {
            type: Boolean,
            default: false
        },
        task: {
            type: String,
            //trim: true,
            maxlength: 255,
            required: true //es necesario??
        },
        tags:[{
            type: String,
            trim: true,
            maxlength: 50
        }],
        productivity:{
            type: Number, // Scale from 1 to 5
            min: 1,
            max: 5
        },
        notes: {
            type: String,
            //trim: true,
            maxlength: 500
        },
        inturrumptions:{
            type: Number, // Count of interruptions
            default: 0
        },
        startTime: {
            type: Date,
            required: true
        },
        endTime: {
            type: Date,
            required: true
        }
    }, { timestamps: true });

// Índices para optimizar consultas
pomodoroSchema.index({ userId: 1, createdAt: -1 })
pomodoroSchema.index({ userId: 1, type: 1 })

// Método para calcular estadísticas
pomodoroSchema.statics.getUserStats = async function(userId,  startDate, endDate) {
    const pipeline = [
        {
            $match: {
                userId: mongoose.Types.ObjectId(userId),
                createdAt: { 
                    $gte: startDate,
                    $lte: endDate 
                }
            }
        },
        {
            $group:{
                _id: null,
                totalSessions: { $sum: 1 },
                   
                completedSessions: { 
                    $sum: { $cond: ["$completed", 1, 0] } 
                },
                totalFocusTime: {
                    $sum: {$cond:[{$eq: ["$type", "work"]}, "$actualDuration", 0]}
                },
                averageProductivity: {
                    $avg: "$productivity"
                },
                totalInterruptions: {
                    $sum: "$inturruptions"
                }
            }
        }
    ]
    
    const result = await this.aggregate(pipeline);
    // Si no hay resultados, retornar un objeto con valores por defecto

    return(
        result[0] || {
            totalSessions: 0,
            completedSessions: 0,
            totalFocusTime: 0,
            averageProductivity: 0,
            totalInterruptions: 0
        }
    );
    
}