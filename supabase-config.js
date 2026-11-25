/**
 * CONFIGURACIÓN DE SUPABASE
 * ==============================================================================
 * Instrucciones:
 * 1. Entra a tu dashboard de Supabase (https://supabase.com).
 * 2. Entra a tu proyecto -> "Project Settings" (ícono de engranaje) -> "API".
 * 3. Copia tu "Project URL" y pégala en SUPABASE_URL.
 * 4. Copia tu clave "anon" "public" y pégala en SUPABASE_ANON_KEY.
 * ==============================================================================
 */

const SUPABASE_CONFIG = {
    // Reemplaza con la URL de tu proyecto Supabase (ej: https://xyzcompany.supabase.co)
    url: "https://bxpdlxhtncjfiepcilng.supabase.co",

    // Reemplaza con tu clave anon/public de Supabase
    anonKey: "sb_publishable_AnnSUPddBNYe0xCO9gj60g_AM6m4sac"
};

// Inicialización del cliente Supabase
(function initSupabase() {
    const isConfigured =
        SUPABASE_CONFIG.url &&
        SUPABASE_CONFIG.anonKey &&
        !SUPABASE_CONFIG.url.includes("TU_SUPABASE_PROJECT_URL") &&
        !SUPABASE_CONFIG.anonKey.includes("TU_SUPABASE_ANON_KEY");

    if (isConfigured && window.supabase) {
        window.supabaseClient = window.supabase.createClient(
            SUPABASE_CONFIG.url,
            SUPABASE_CONFIG.anonKey
        );
        console.log("✅ Supabase inicializado correctamente.");
    } else {
        console.info(
            "ℹ️ Supabase aún no está configurado en supabase-config.js. Mostrando contenido estático por defecto."
        );
        window.supabaseClient = null;
    }
})();
