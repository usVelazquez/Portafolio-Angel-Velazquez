-- ==============================================================================
-- SCRIPT DE CONFIGURACIÓN Y MIGRACIÓN PARA SUPABASE
-- Portafolio de Ángel Velázquez
-- ==============================================================================
-- Instrucciones:
-- 1. Inicia sesión en https://supabase.com y abre tu proyecto.
-- 2. Ve al menú lateral "SQL Editor".
-- 3. Haz clic en "New query" (Nueva consulta), pega todo este contenido y presiona "Run".
-- ==============================================================================

-- 1. Habilitar extensión para generación de identificadores UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. CREACIÓN DE TABLAS
-- ==============================================================================

-- TABLA: EXPERIENCIAS (Empleos y Trayectoria)
CREATE TABLE IF NOT EXISTS public.experiencias (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    puesto TEXT NOT NULL,
    empresa TEXT NOT NULL,
    periodo TEXT NOT NULL, -- Ej: "Nov 2025 — Jul 2026"
    descripcion TEXT[] DEFAULT '{}'::TEXT[], -- Lista de actividades o viñetas
    orden INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT true
);

-- TABLA: PROYECTOS
CREATE TABLE IF NOT EXISTS public.proyectos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    titulo TEXT NOT NULL,
    estado TEXT DEFAULT 'Proyecto personal', -- Ej: "En diseño", "En desarrollo", "Proyecto personal", "Completado"
    descripcion TEXT NOT NULL,
    siglas TEXT DEFAULT '</>', -- Visual tipo texto/siglas si no hay imagen (ej: "TRG.", "</>")
    imagen_url TEXT, -- URL de imagen opcional
    tecnologias TEXT[] DEFAULT '{}'::TEXT[], -- Etiquetas/Skills
    enlace_github TEXT, -- Opcional
    enlace_demo TEXT, -- Opcional
    orden INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT true
);

-- ==============================================================================
-- 3. SEGURIDAD: ROW LEVEL SECURITY (RLS)
-- ==============================================================================
ALTER TABLE public.experiencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proyectos ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas previas si existieran para evitar duplicados
DROP POLICY IF EXISTS "Lectura publica de experiencias" ON public.experiencias;
DROP POLICY IF EXISTS "Modificacion total para usuarios autenticados en experiencias" ON public.experiencias;
DROP POLICY IF EXISTS "Lectura publica de proyectos" ON public.proyectos;
DROP POLICY IF EXISTS "Modificacion total para usuarios autenticados en proyectos" ON public.proyectos;

-- A) POLÍTICAS DE LECTURA PÚBLICA
-- Cualquier visitante de tu portafolio puede consultar los datos sin necesidad de iniciar sesión
CREATE POLICY "Lectura publica de experiencias"
    ON public.experiencias FOR SELECT
    TO anon
    USING (activo = true);

CREATE POLICY "Lectura publica de proyectos"
    ON public.proyectos FOR SELECT
    TO anon
    USING (activo = true);

-- B) POLÍTICAS DE GESTIÓN PARA EL ADMINISTRADOR
-- Solo tú (usuario autenticado con email y contraseña) puedes crear, editar o eliminar registros
CREATE POLICY "Modificacion total para usuarios autenticados en experiencias"
    ON public.experiencias FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Modificacion total para usuarios autenticados en proyectos"
    ON public.proyectos FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- ==============================================================================
-- 4. DATOS INICIALES (MIGRACIÓN DESDE TU PORTAFOLIO ACTUAL)
-- ==============================================================================

-- Insertar experiencias iniciales (solo si la tabla está vacía)
INSERT INTO public.experiencias (puesto, empresa, periodo, descripcion, orden, activo)
SELECT * FROM (VALUES
    (
        'Auxiliar de Sistemas',
        'VMC Project Management',
        'Nov 2025 — Jul 2026',
        ARRAY[
            'Soporte técnico de primer nivel a más de 50 usuarios internos.',
            'Resolución de incidencias informáticas con tiempos de respuesta menores a dos horas.',
            'Instalación, configuración y mantenimiento de equipos, impresoras y periféricos.',
            'Implementación de cableado estructurado y cámaras IP.',
            'Configuración de correo empresarial y soporte básico en servidores.'
        ],
        1,
        true
    ),
    (
        'Practicante de Sistemas y TI',
        'Central de Actuación Logística',
        'May 2025 — Nov 2025',
        ARRAY[
            'Mantenimiento preventivo y correctivo de equipos de cómputo.',
            'Instalación de infraestructura de red y cableado RJ45.',
            'Diagnóstico, seguimiento y resolución de tickets de soporte.'
        ],
        2,
        true
    ),
    (
        'Asesor de Telecomunicaciones',
        'Telcel (Anexa)',
        'Ene 2023 — Jul 2024',
        ARRAY[
            'Configuración y aprovisionamiento de líneas de operadores móviles virtuales.',
            'Diagnóstico y solución de inconsistencias en servicios de telecomunicaciones.',
            'Atención técnica de líneas corporativas y proveedores.'
        ],
        3,
        true
    ),
    (
        'Técnico Instalador de TPV',
        'TPV Solution',
        'Ago 2022 — Ene 2023',
        ARRAY[
            'Instalación, configuración y mantenimiento de terminales de punto de venta.',
            'Capacitación técnica a usuarios.',
            'Gestión de inventarios de equipos tecnológicos mediante Excel.'
        ],
        4,
        true
    ),
    (
        'Técnico Instalador de Telemetría',
        'Métrica Móvil',
        'Jul 2021 — Ago 2022',
        ARRAY[
            'Instalación y diagnóstico de dispositivos de telemetría.',
            'Armado y revisión de circuitos electrónicos para vehículos y transporte de carga.',
            'Servicios técnicos a empresas automotrices y de logística.'
        ],
        5,
        true
    ),
    (
        'Agente de Soporte Técnico',
        'Telmex Call Center',
        'Feb 2020 — Jul 2021',
        ARRAY[
            'Diagnóstico remoto de incidencias de conectividad y telefonía VoIP.',
            'Configuración y soporte de módems, routers y redes Wi-Fi.',
            'Gestión y escalamiento de incidentes críticos.'
        ],
        6,
        true
    )
) AS v(puesto, empresa, periodo, descripcion, orden, activo)
WHERE NOT EXISTS (SELECT 1 FROM public.experiencias);

-- Insertar proyectos iniciales (solo si la tabla está vacía)
INSERT INTO public.proyectos (titulo, estado, descripcion, siglas, tecnologias, enlace_github, enlace_demo, orden, activo)
SELECT * FROM (VALUES
    (
        'TRG — Toque, Registra, Gestiona',
        'En diseño',
        'Concepto de aplicación para registrar gastos personales de manera rápida y sencilla. Su propuesta contempla la integración con Atajos de Apple para capturar movimientos sin abrir una aplicación manualmente.',
        'TRG.',
        ARRAY['Finanzas personales', 'API REST (planeada)', 'Atajos de Apple'],
        NULL,
        NULL,
        1,
        true
    ),
    (
        'Portafolio Web',
        'Proyecto personal',
        'Sitio web personal desarrollado con HTML, CSS y JavaScript. Diseñado para presentar mi trayectoria, conocimientos técnicos y proyectos mediante una interfaz moderna, accesible y adaptable a distintos dispositivos.',
        '</>',
        ARRAY['HTML5', 'CSS3', 'JavaScript', 'Responsive Design'],
        NULL,
        NULL,
        2,
        true
    ),
    (
        'Sistema de tickets',
        'Proyecto personal',
        'Sistema web desarrollada con HTML, CSS, JS y PHP. Diseñada para registrar incidencias y documentar el proceso que se lleva para resolverlo con una interfas intuitiva y adaptable a cualquier dispositivo.',
        'TICKETS',
        ARRAY['Mesa de ayuda', 'Responsive Design', 'PHP'],
        NULL,
        NULL,
        3,
        true
    )
) AS v(titulo, estado, descripcion, siglas, tecnologias, enlace_github, enlace_demo, orden, activo)
WHERE NOT EXISTS (SELECT 1 FROM public.proyectos);
