import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['public/css/auth/login.css','public/css/compartido/topbar.css','public/css/dashboard/dashboard.css','public/css/dashboard_usuario.css','public/css/dashboard.css','public/css/estilos.css','public/js/auth/login.js','public/js/compartido/topbar.js','public/js/scrip.js','public/js/validaciones.js'],
            refresh: true,
        }),
        tailwindcss(),
    ],
    server: {
        watch: {
            ignored: ['**/storage/framework/views/**'],
        },
    },
});
