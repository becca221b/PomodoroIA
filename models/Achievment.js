const mongoose = require('mongoose');

const achievementSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            unique: true
        },
        description: {
            type: String,
            required: true
        },
        icon: {
            type: String,
            required: true
        },
        category: {
            type: String,
            enum: ['pomodoro', 'streak', 'productivity', 'emotion', 'milestone'],// !!! VER CATEGORIAS A DEFINIR !!!
            required: true
        },
        criteria: {
            type: String,
            enum: ['total_sessions', 'streak_days', 'focus_time', 'productivity_avg', 'emotion_score'], // !!! VER CRITERIOS A DEFINIR !!!
            required: true
        }
    },{ timestamps: true }
)