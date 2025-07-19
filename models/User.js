const mongoose = require('mongoose');
const { use } = require('react');

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
                type: Number,// en minutos
                default: 0
            },
            streak : {
                type: Number,
                default: 0
            },
            lastPomodoro: Date
        },
        preferences: {
            pomodoroDuration: {
                type: Number,
                default: 25 // en minutos
            },
            shortBreakDuration: {
                type: Number,
                default: 5 // en minutos
            },
            longBreakDuration: {
                type: Number,
                default: 15 // en minutos
            },
            sessionsBeforeLongBreak: {
                type: Number,
                default: 4 // número de pomodoros antes de un descanso largo
            },
            notifications: {
                type: Boolean,
                default: true // si el usuario quiere recibir notificaciones,
            },
            soundEnabled: {
                type: Boolean,
                default: true // si el usuario quiere sonidos
            }
        },
        achievements: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref: 'Achievement'
            }
        ],
    },
    {
        timestamps: true
    }
)


//Hasheo de pasword antes de guardar
userSchema.pre('save', async function(next) {
    if(!this.isModified('password')) return next();
    try {
        const salt = await bcrypt.genSalt(10);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    }catch(err) {
        next(err);
    }
})

// Método para comparar contraseñas
UserSchema.methods.comparePassword = async function(candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
}

// Método para actualizar el nivel y la experiencia del usuario
UserSchema.methods.addExperence = function(points) {
    this.profile.experience += points;

    // Calcular el nuevo nivel (cada 100 puntos sube 1 nivel)
    const newLevel = Math.floor(this.profile.experience / 100) + 1;
    if (newLevel > this.profile.level) {
        this.profile.level = newLevel;
        return { levelUp: true, newLevel };
    }

    return {levelUp: false, newLevel: this.profile.level};
}

module.exports = mongoose.model('User', UserSchema);