# Radar Comercial Cuba

Plataforma de inteligencia comercial para Cuba: organiza publicaciones de grupos de WhatsApp y permite consultar productos, precios publicados, fotografías, vendedores, zonas, ofertas y evolución histórica.

## Módulos
- Inicio y panel de indicadores.
- Catálogo de productos con fotos, moneda, unidad, vendedor, zona, fuente y estado de verificación.
- Comparador de precios con control de moneda y unidad.
- Historial de publicaciones y observaciones de precios.
- Directorio de negocios y vendedores a partir de información expresamente publicada.
- Ofertas y oportunidades comerciales.
- Calculadoras de kilogramos/libra, precio unitario y conversión con tasa manual.
- Importación de historiales TXT de WhatsApp, registro de grupos y conservación de mensajes originales.
- Administración y copias de seguridad JSON.

## Reglas de integridad
- No inventar productos, precios, monedas, vendedores, ubicaciones ni disponibilidad.
- Una publicación histórica no se considera inventario vigente.
- Los precios importados se marcan como no verificados hasta confirmación del vendedor.
- Se conserva grupo, remitente, fecha y texto original cuando están presentes.
- Los números de teléfono personales no se publican sin autorización.
- La lectura de WhatsApp no es automática: se incorporan exportaciones facilitadas por el usuario o integraciones autorizadas.
- Si el ZIP no contiene archivos multimedia, las fotografías no pueden recuperarse desde el texto.

## Estado técnico actual
La interfaz web funciona como aplicación estática y guarda los datos en el almacenamiento local del navegador. La sincronización entre dispositivos, autenticación multiusuario y almacenamiento centralizado de fotos requieren conectar el proyecto Supabase correcto y configurar sus tablas, políticas RLS y Storage. No se debe conectar ni modificar otro proyecto de Supabase por error.

## Despliegue
Repositorio preparado para GitHub Pages desde la rama `main`, archivo `index.html`.
