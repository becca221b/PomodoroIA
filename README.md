# MVP Entrenamiento Cognitivo para Alzheimer Temprano

## 🧠 Descripción del Proyecto

Este MVP (Producto Mínimo Viable) es una aplicación web desarrollada con **Oracle APEX** y **Oracle Autonomous Database** diseñada específicamente para ayudar a pacientes con Alzheimer temprano a través de:

- **Gamificación**: Sistema de puntos, logros, niveles y recompensas
- **Análisis de Estadísticas**: Seguimiento detallado del progreso cognitivo
- **IA para Recomendaciones**: Algoritmos inteligentes que sugieren actividades basadas en emociones y rendimiento
- **Seguimiento Emocional**: Registro y análisis del estado emocional diario

## 🎯 Características Principales

### 🎮 Gamificación
- Sistema de puntos y niveles progresivos
- 15 logros diferentes para motivar la participación
- Racha de días consecutivos jugando
- Recompensas visuales y feedback positivo

### 📊 Análisis de Estadísticas
- Dashboard interactivo con métricas clave
- Gráficos de evolución cognitiva
- Análisis de rendimiento por categorías
- Mapa de calor de actividad semanal
- Distribución de estados emocionales

### 🤖 IA y Recomendaciones
- Recomendaciones basadas en estado emocional actual
- Sugerencias adaptadas al rendimiento histórico
- Algoritmos de rutina personalizada
- Sistema de confianza en recomendaciones

### 💙 Seguimiento Emocional
- 10 emociones diferentes con intensidad del 1-5
- Interfaz visual intuitiva para selección
- Correlación entre emociones y rendimiento
- Notas opcionales para contexto adicional

### 🧩 Juegos Cognitivos
8 categorías de actividades especializadas:
1. **Memoria**: Parejas de imágenes, secuencias, álbum familiar
2. **Atención**: Diferencias, seguimiento visual, clasificación
3. **Lenguaje**: Completar palabras, rimas, historias familiares
4. **Función Ejecutiva**: Planificación, laberintos
5. **Orientación**: Calendario, navegación espacial
6. **Reconocimiento**: Objetos cotidianos, caras conocidas
7. **Coordinación**: Trazado, secuencias táctiles
8. **Relajación**: Respiración guiada, jardín zen, música

## 🏗️ Arquitectura del Sistema

### Base de Datos (Oracle Autonomous Database)
```
📁 database/
├── 01_create_tables.sql          # Esquema principal
├── 02_insert_initial_data.sql    # Datos iniciales
└── 03_ai_recommendation_package.sql # Motor de IA
```

### Aplicación APEX
```
📁 apex/
├── application_structure.sql     # Estructura base
└── pages/
    ├── page_02_dashboard.sql     # Panel principal
    ├── page_03_emotion_checkin.sql # Registro emocional
    └── page_11_statistics.sql    # Estadísticas
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Oracle Autonomous Database (Always Free tier disponible)
- Oracle APEX 21.1 o superior
- Navegador web moderno (Chrome, Firefox, Safari, Edge)

### Paso 1: Configurar la Base de Datos

1. **Crear Oracle Autonomous Database**
   ```bash
   # Acceder a Oracle Cloud Console
   # Crear nueva Autonomous Database (ATP o ADW)
   # Configurar usuario ALZHEIMER_MVP
   ```

2. **Ejecutar Scripts de Base de Datos**
   ```sql
   -- Conectar como ALZHEIMER_MVP
   @database/01_create_tables.sql
   @database/02_insert_initial_data.sql
   @database/03_ai_recommendation_package.sql
   ```

### Paso 2: Configurar Oracle APEX

1. **Acceder a APEX Workspace**
   ```
   URL: https://[tu-autonomous-db]-apex.adb.[region].oraclecloudapps.com/ords/
   ```

2. **Importar Aplicación**
   ```sql
   -- Ejecutar en SQL Workshop
   @apex/application_structure.sql
   @apex/pages/page_02_dashboard.sql
   @apex/pages/page_03_emotion_checkin.sql
   @apex/pages/page_11_statistics.sql
   ```

3. **Configurar Autenticación**
   - Esquema: `ALZHEIMER_MVP`
   - Función de autenticación: `authenticate_patient`

### Paso 3: Datos de Prueba

```sql
-- Crear paciente de prueba
INSERT INTO patients (username, email, first_name, last_name, date_of_birth)
VALUES ('demo_user', 'demo@ejemplo.com', 'María', 'González', DATE '1955-03-15');

-- Crear estadísticas iniciales
INSERT INTO patient_stats (patient_id, stat_date, current_level, total_points)
VALUES (1, TRUNC(SYSDATE), 1, 0);
```

## 📱 Uso de la Aplicación

### Para Pacientes

1. **Inicio de Sesión**
   - Ingresar nombre de usuario
   - Acceso directo al dashboard personalizado

2. **Registro Emocional Diario**
   - Seleccionar emoción actual
   - Definir intensidad (1-5)
   - Agregar notas opcionales

3. **Jugar Actividades**
   - Seguir recomendaciones de IA
   - Explorar categorías por interés
   - Completar sesiones para ganar puntos

4. **Seguir Progreso**
   - Ver estadísticas personales
   - Revisar logros obtenidos
   - Analizar evolución cognitiva

### Para Cuidadores

1. **Panel de Cuidador** (Página 15)
   - Monitorear progreso del paciente
   - Recibir notificaciones importantes
   - Revisar patrones emocionales

## 🔧 Configuración Avanzada

### Personalización de Juegos

```sql
-- Agregar nuevo juego
INSERT INTO games (category_id, game_name, description, difficulty_level, points_base)
VALUES (1, 'Nuevo Juego Memoria', 'Descripción del juego', 2, 15);
```

### Configurar Nuevos Logros

```sql
-- Crear logro personalizado
INSERT INTO achievements (achievement_name, description, category, criteria_json)
VALUES ('Mi Logro', 'Descripción del logro', 'CUSTOM', '{"custom_criteria": true}');
```

### Ajustar Algoritmo de IA

```sql
-- Modificar parámetros del motor de recomendaciones
-- Ver: database/03_ai_recommendation_package.sql
-- Función: generate_emotion_based_recommendations
```

## 📊 Métricas y KPIs

### Métricas de Paciente
- **Puntuación Cognitiva**: 0-100 (combinación de rendimiento, consistencia y finalización)
- **Nivel**: 1-5 basado en puntos acumulados
- **Racha**: Días consecutivos de actividad
- **Tiempo de Sesión**: Promedio de minutos por día

### Métricas de Sistema
- Tasa de finalización de juegos
- Distribución de emociones
- Efectividad de recomendaciones IA
- Engagement por categoría

## 🔒 Seguridad y Privacidad

### Protección de Datos
- Encriptación en tránsito y reposo (Oracle ADB)
- Autenticación segura por sesión
- Anonimización de datos sensibles
- Cumplimiento HIPAA/GDPR

### Backup y Recuperación
```sql
-- Backup automático Oracle Autonomous Database
-- Retención: 60 días
-- Recuperación point-in-time disponible
```

## 🚨 Solución de Problemas

### Problemas Comunes

1. **Error de Conexión a Base de Datos**
   ```
   Verificar:
   - Wallet de conexión actualizado
   - Credenciales correctas
   - Red/firewall configurado
   ```

2. **Recomendaciones IA No Aparecen**
   ```sql
   -- Ejecutar manualmente
   BEGIN
       ai_recommendations_pkg.generate_emotion_based_recommendations(1);
   END;
   ```

3. **Gráficos No Cargan**
   ```
   Verificar:
   - Chart.js CDN accesible
   - JavaScript habilitado
   - Datos suficientes en patient_stats
   ```

### Logs y Monitoreo

```sql
-- Ver logs de aplicación
SELECT * FROM apex_debug_messages 
WHERE application_id = 100 
ORDER BY message_timestamp DESC;

-- Monitorear rendimiento
SELECT * FROM patient_stats 
WHERE stat_date >= SYSDATE - 7
ORDER BY cognitive_score DESC;
```

## 🔄 Actualizaciones y Mantenimiento

### Mantenimiento Rutinario
- **Diario**: Backup automático, limpieza de sesiones
- **Semanal**: Análisis de rendimiento, optimización de consultas
- **Mensual**: Revisión de métricas, actualización de algoritmos IA

### Roadmap de Mejoras
- [ ] Integración con dispositivos wearables
- [ ] Análisis predictivo avanzado
- [ ] Multiplayer para socialización
- [ ] Integración con historia clínica
- [ ] App móvil nativa

## 👥 Soporte y Contribución

### Contacto
- **Desarrollador**: [Tu Nombre]
- **Email**: [tu-email@ejemplo.com]
- **Documentación**: Este README.md

### Contribuir
1. Fork del repositorio
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para detalles.

## 🙏 Agradecimientos

- **Oracle**: Por la plataforma APEX y Autonomous Database
- **Comunidad Alzheimer**: Por la retroalimentación y validación
- **Desarrolladores APEX**: Por recursos y mejores prácticas
- **Investigadores en Neurociencia**: Por la base científica

---

**Nota**: Este MVP está diseñado para complementar, no reemplazar, el tratamiento médico profesional. Siempre consulte con profesionales de la salud para el manejo integral del Alzheimer.

## 🔗 Enlaces Útiles

- [Oracle APEX Documentation](https://docs.oracle.com/en/database/oracle/application-express/)
- [Oracle Autonomous Database](https://www.oracle.com/autonomous-database/)
- [Alzheimer's Association](https://www.alz.org/)
- [Cognitive Training Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4055506/)