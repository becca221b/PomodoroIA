const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
    {
        username: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            minlength: 3,
            maxlength: 30
        },
        password: {
            type: String,
            required: true,
            minlength: 6
        },
        email: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true,
            match: /.+\@.+\..+/
        },
        profile: {
            avatar: String,
            level: {
                type: Number,
                default: 1
            },
            experience: {
                type: Number,
                default: 0
            },
            totalPomodoroSessions: {
                type: Number,
                default: 0
            },
            totalFocusTime: {
                type: Number,
                default: 0
            },
            streak : {
                type: Number,
                default: 0
            },
            lastPomodoro: Date
        }
    },
    {
        timestamps: true
    }
)