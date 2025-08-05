-- Initial Data Population for Alzheimer's MVP
-- Insert initial emotions
INSERT INTO emotions (emotion_name, emotion_color, description, is_positive) VALUES
('Feliz', '#FFD700', 'Estado de alegría y satisfacción', 'Y'),
('Triste', '#4169E1', 'Estado de melancolía o pena', 'N'),
('Ansioso', '#FF6347', 'Estado de preocupación o nerviosismo', 'N'),
('Tranquilo', '#90EE90', 'Estado de paz y serenidad', 'Y'),
('Confundido', '#DDA0DD', 'Estado de desorientación mental', 'N'),
('Motivado', '#FF69B4', 'Estado de energía y determinación', 'Y'),
('Frustrado', '#DC143C', 'Estado de irritación por obstáculos', 'N'),
('Relajado', '#20B2AA', 'Estado de calma y descanso', 'Y'),
('Nostálgico', '#F0E68C', 'Estado de añoranza por el pasado', 'Y'),
('Enérgico', '#FF4500', 'Estado de vitalidad y dinamismo', 'Y');

-- Insert game categories
INSERT INTO game_categories (category_name, description, icon_class, cognitive_area, difficulty_level) VALUES
('Memoria', 'Juegos para fortalecer la memoria a corto y largo plazo', 'fa-brain', 'Memory', 2),
('Atención', 'Actividades para mejorar la concentración y el enfoque', 'fa-eye', 'Attention', 2),
('Lenguaje', 'Ejercicios para mantener habilidades verbales y comunicativas', 'fa-comments', 'Language', 2),
('Función Ejecutiva', 'Tareas para planificación y resolución de problemas', 'fa-cogs', 'Executive Function', 3),
('Orientación', 'Actividades para mantener la orientación temporal y espacial', 'fa-compass', 'Orientation', 1),
('Reconocimiento', 'Juegos de identificación de objetos, personas y lugares', 'fa-search', 'Recognition', 2),
('Coordinación', 'Ejercicios para mantener habilidades motoras finas', 'fa-hand-paper', 'Motor Skills', 1),
('Relajación', 'Actividades para reducir estrés y promover calma', 'fa-leaf', 'Emotional Regulation', 1);

-- Insert games and activities
INSERT INTO games (category_id, game_name, description, instructions, difficulty_level, estimated_duration, points_base, cognitive_benefits, recommended_emotions) VALUES
-- Memory Games
(1, 'Parejas de Imágenes', 'Encuentra las parejas de cartas idénticas', 'Voltea las cartas de dos en dos para encontrar las parejas. Intenta recordar dónde están las cartas que ya has visto.', 2, 10, 20, 'Memoria visual, concentración', '1,4,6'),
(1, 'Secuencia de Colores', 'Repite la secuencia de colores mostrada', 'Observa la secuencia de colores y repítela en el mismo orden. La secuencia se hará más larga cada vez.', 3, 15, 25, 'Memoria secuencial, atención', '1,6,10'),
(1, 'Álbum Familiar', 'Identifica familiares en fotografías', 'Mira las fotografías y selecciona el nombre correcto de cada familiar mostrado.', 1, 8, 15, 'Memoria episódica, reconocimiento facial', '1,9'),

-- Attention Games
(2, 'Encuentra las Diferencias', 'Localiza las diferencias entre dos imágenes', 'Compara las dos imágenes y toca las áreas donde encuentres diferencias.', 2, 12, 18, 'Atención selectiva, percepción visual', '1,4,6'),
(2, 'Sigue el Punto', 'Mantén la vista en el punto móvil', 'Sigue el punto rojo con tu mirada mientras se mueve por la pantalla.', 1, 5, 10, 'Atención sostenida, seguimiento visual', '4,8'),
(2, 'Clasificación de Colores', 'Agrupa objetos por color', 'Arrastra cada objeto al contenedor del color correspondiente.', 2, 10, 15, 'Atención dividida, categorización', '1,6'),

-- Language Games
(3, 'Completar Palabras', 'Completa las palabras con las letras faltantes', 'Lee la palabra incompleta y selecciona las letras que faltan para completarla.', 2, 8, 15, 'Vocabulario, procesamiento verbal', '1,6'),
(3, 'Rimas y Sonidos', 'Encuentra palabras que riman', 'Escucha la palabra y selecciona cuál de las opciones rima con ella.', 2, 10, 18, 'Conciencia fonológica, memoria auditiva', '1,9'),
(3, 'Historias Familiares', 'Cuenta historias sobre fotografías familiares', 'Mira la fotografía y cuenta lo que recuerdas sobre ese momento o persona.', 1, 15, 25, 'Narrativa, memoria autobiográfica', '1,9,6'),

-- Executive Function Games
(4, 'Planifica tu Día', 'Organiza actividades en orden lógico', 'Arrastra las actividades diarias en el orden correcto desde la mañana hasta la noche.', 3, 15, 30, 'Planificación, secuenciación temporal', '6,10'),
(4, 'Resuelve el Laberinto', 'Encuentra la salida del laberinto', 'Usa las flechas para guiar el personaje hacia la salida del laberinto.', 3, 12, 25, 'Resolución de problemas, planificación espacial', '1,6'),

-- Orientation Games
(5, 'Calendario Interactivo', 'Identifica la fecha actual', 'Selecciona el día, mes y año correctos en el calendario.', 1, 5, 10, 'Orientación temporal', '4,8'),
(5, 'Mi Casa Virtual', 'Navega por las habitaciones de tu casa', 'Explora las diferentes habitaciones y identifica los objetos en cada una.', 1, 10, 15, 'Orientación espacial, memoria espacial', '4,8,9'),

-- Recognition Games
(6, 'Objetos Cotidianos', 'Identifica objetos de uso diario', 'Mira el objeto y selecciona su nombre correcto de las opciones disponibles.', 1, 8, 12, 'Reconocimiento visual, vocabulario', '1,4'),
(6, 'Caras Conocidas', 'Reconoce personas familiares', 'Observa la fotografía y selecciona el nombre de la persona mostrada.', 2, 10, 20, 'Reconocimiento facial, memoria social', '1,9'),

-- Coordination Games
(7, 'Traza el Camino', 'Sigue la línea con el dedo', 'Mantén el dedo sobre la línea mientras la sigues desde el inicio hasta el final.', 1, 8, 12, 'Coordinación ojo-mano, control motor', '4,8'),
(7, 'Toca los Círculos', 'Toca los círculos en el orden correcto', 'Toca los círculos numerados en orden ascendente lo más rápido que puedas.', 2, 10, 15, 'Coordinación, secuenciación', '1,6,10'),

-- Relaxation Activities
(8, 'Respiración Guiada', 'Ejercicio de respiración relajante', 'Sigue las instrucciones visuales para inhalar y exhalar profundamente.', 1, 10, 15, 'Relajación, control emocional', '2,3,7,8'),
(8, 'Jardín Zen', 'Crea patrones relajantes en la arena', 'Arrastra el dedo por la arena para crear patrones que te resulten relajantes.', 1, 15, 20, 'Relajación, creatividad', '2,3,4,8'),
(8, 'Música y Recuerdos', 'Escucha música familiar', 'Escucha canciones de tu época y comparte qué recuerdos te traen.', 1, 20, 25, 'Relajación, memoria musical', '2,9,8');

-- Insert achievements
INSERT INTO achievements (achievement_name, description, icon_class, badge_color, points_required, category, criteria_json) VALUES
('Primer Paso', 'Completa tu primer juego', 'fa-baby', '#FFD700', 0, 'COMPLETION', '{"games_completed": 1}'),
('Jugador Constante', 'Juega 7 días seguidos', 'fa-calendar-check', '#32CD32', 50, 'STREAK', '{"consecutive_days": 7}'),
('Experto en Memoria', 'Completa 10 juegos de memoria', 'fa-brain', '#FF69B4', 100, 'CATEGORY', '{"category": "Memoria", "games_completed": 10}'),
('Maestro de Atención', 'Completa 10 juegos de atención', 'fa-eye', '#4169E1', 100, 'CATEGORY', '{"category": "Atención", "games_completed": 10}'),
('Comunicador', 'Completa 10 juegos de lenguaje', 'fa-comments', '#FF6347', 100, 'CATEGORY', '{"category": "Lenguaje", "games_completed": 10}'),
('Planificador', 'Completa 5 juegos de función ejecutiva', 'fa-cogs', '#8A2BE2', 150, 'CATEGORY', '{"category": "Función Ejecutiva", "games_completed": 5}'),
('Explorador', 'Completa juegos de todas las categorías', 'fa-globe', '#FF4500', 200, 'VARIETY', '{"all_categories": true}'),
('Puntuación Alta', 'Obtén 1000 puntos totales', 'fa-trophy', '#FFD700', 1000, 'SCORE', '{"total_points": 1000}'),
('Maratonista', 'Juega por más de 2 horas en total', 'fa-running', '#32CD32', 0, 'TIME', '{"total_minutes": 120}'),
('Perfeccionista', 'Completa un juego sin errores', 'fa-star', '#FFD700', 0, 'PERFORMANCE', '{"perfect_game": true}'),
('Zen Master', 'Completa 5 actividades de relajación', 'fa-leaf', '#90EE90', 75, 'CATEGORY', '{"category": "Relajación", "games_completed": 5}'),
('Emocionalmente Consciente', 'Registra tu estado emocional 10 veces', 'fa-heart', '#FF69B4', 50, 'EMOTION', '{"emotion_logs": 10}'),
('Superación Personal', 'Mejora tu puntuación en el mismo juego 3 veces', 'fa-chart-line', '#32CD32', 0, 'IMPROVEMENT', '{"score_improvements": 3}'),
('Veterano', 'Juega durante 30 días (no necesariamente consecutivos)', 'fa-medal', '#B8860B', 300, 'CONSISTENCY', '{"total_days_played": 30}'),
('Campeón Semanal', 'Sé el mejor jugador de la semana', 'fa-crown', '#FFD700', 0, 'WEEKLY', '{"weekly_champion": true}');

COMMIT;