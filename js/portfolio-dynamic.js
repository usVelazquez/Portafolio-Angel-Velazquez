/**
 * CARGADOR DINÁMICO DESDE SUPABASE
 * ==============================================================================
 * Este script consulta la base de datos de Supabase para obtener las experiencias
 * y proyectos actualizados y los renderiza en index.html.
 * Si Supabase no está configurado o hay un problema de red, el sitio conserva
 * automáticamente el contenido HTML original como respaldo (fallback).
 * ==============================================================================
 */

document.addEventListener("DOMContentLoaded", async () => {
    // Si Supabase no está configurado, salir silenciosamente (se muestra el HTML estático)
    if (!window.supabaseClient) {
        return;
    }

    try {
        await Promise.all([
            cargarExperiencias(),
            cargarProyectos()
        ]);
    } catch (err) {
        console.warn("No se pudieron cargar datos dinámicos de Supabase, manteniendo contenido estático:", err);
    }
});

/**
 * Función auxiliar para sanitizar cadenas HTML y evitar inyecciones
 */
function escapeHTML(str) {
    if (!str) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

/**
 * Carga y renderiza la lista de empleos / experiencias
 */
async function cargarExperiencias() {
    const timelineContainer = document.querySelector(".timeline");
    if (!timelineContainer) return;

    const { data: experiencias, error } = await window.supabaseClient
        .from("experiencias")
        .select("*")
        .eq("activo", true)
        .order("orden", { ascending: true });

    if (error) {
        console.error("Error al obtener experiencias:", error);
        return;
    }

    if (!experiencias || experiencias.length === 0) {
        return; // Mantiene el contenido por defecto
    }

    // Generar el HTML de las experiencias
    const html = experiencias.map(exp => {
        const puesto = escapeHTML(exp.puesto);
        const empresa = escapeHTML(exp.empresa);
        const periodo = escapeHTML(exp.periodo);
        const items = Array.isArray(exp.descripcion) ? exp.descripcion : [];

        const viñetasHtml = items
            .map(desc => `<li>${escapeHTML(desc)}</li>`)
            .join("");

        return `
            <article class="timeline-item">
                <div class="experience-card">
                    <p class="experience-date">
                        <time>${periodo}</time>
                    </p>
                    <h3>${puesto}</h3>
                    <span class="experience-company">${empresa}</span>
                    <ul class="experience-description">
                        ${viñetasHtml}
                    </ul>
                </div>
            </article>
        `;
    }).join("");

    timelineContainer.innerHTML = html;
}

/**
 * Carga y renderiza la lista de proyectos
 */
async function cargarProyectos() {
    const projectsGrid = document.querySelector(".projects-grid");
    if (!projectsGrid) return;

    const { data: proyectos, error } = await window.supabaseClient
        .from("proyectos")
        .select("*")
        .eq("activo", true)
        .order("orden", { ascending: true });

    if (error) {
        console.error("Error al obtener proyectos:", error);
        return;
    }

    if (!proyectos || proyectos.length === 0) {
        return; // Mantiene el contenido por defecto
    }

    // Generar el HTML de los proyectos
    const html = proyectos.map(proj => {
        const titulo = escapeHTML(proj.titulo);
        const estado = escapeHTML(proj.estado || "Proyecto");
        const descripcion = escapeHTML(proj.descripcion);
        const siglas = escapeHTML(proj.siglas || "</>");
        const imagenUrl = proj.imagen_url ? escapeHTML(proj.imagen_url) : null;
        const tecnologias = Array.isArray(proj.tecnologias) ? proj.tecnologias : [];
        const enlaceGithub = proj.enlace_github ? escapeHTML(proj.enlace_github) : null;
        const enlaceDemo = proj.enlace_demo ? escapeHTML(proj.enlace_demo) : null;

        const visualHtml = imagenUrl
            ? `<img src="${imagenUrl}" alt="${titulo}" style="width: 100%; height: 100%; object-fit: cover;">`
            : `<span aria-hidden="true">${siglas}</span>`;

        const tagsHtml = tecnologias.length > 0
            ? `<ul class="skill-tags">
                ${tecnologias.map(t => `<li class="skill-tag">${escapeHTML(t)}</li>`).join("")}
               </ul>`
            : "";

        const linksHtml = (enlaceGithub || enlaceDemo)
            ? `<div class="project-links" style="margin-top: 20px; display: flex; flex-wrap: wrap; gap: 16px;">
                ${enlaceGithub ? `<a href="${enlaceGithub}" target="_blank" rel="noopener noreferrer" style="color: var(--primary); font-size: 0.85rem; font-weight: 500; display: inline-flex; align-items: center; gap: 6px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4"/><path d="M9 18c-4.51 2-5-2-7-2"/></svg>
                    Código fuente &rarr;
                </a>` : ""}
                ${enlaceDemo ? `<a href="${enlaceDemo}" target="_blank" rel="noopener noreferrer" style="color: var(--secondary); font-size: 0.85rem; font-weight: 500; display: inline-flex; align-items: center; gap: 6px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
                    Ver demostración &rarr;
                </a>` : ""}
               </div>`
            : "";

        return `
            <article class="project-card">
                <div class="project-visual">
                    ${visualHtml}
                </div>
                <div class="project-content">
                    <span class="project-status">${estado}</span>
                    <h3>${titulo}</h3>
                    <p>${descripcion}</p>
                    ${tagsHtml}
                    ${linksHtml}
                </div>
            </article>
        `;
    }).join("");

    projectsGrid.innerHTML = html;
}
