# LazyPDF

Aplicación nativa para macOS que une varios archivos PDF en un único documento. También permite abrir PDFs protegidos con contraseña y exportar una copia unificada sin bloqueo.

## Funciones

- Añadir varios PDFs desde el selector de archivos o arrastrándolos a la ventana.
- Consultar el número de páginas y una miniatura de cada documento.
- Cambiar el orden de los PDFs antes de unirlos.
- Quitar documentos de la lista o vaciarla por completo.
- Desbloquear PDFs protegidos introduciendo su contraseña.
- Exportar el resultado a la ubicación y con el nombre elegidos.

## Uso

1. Abre la aplicación y pulsa **Agregar**, o arrastra los PDFs a la cola.
2. Ordena los documentos con las flechas si lo necesitas.
3. Introduce y confirma la contraseña de cada PDF bloqueado.
4. Pulsa **Unir PDFs**, elige dónde guardar el archivo y confirma la exportación.

El PDF generado contiene todas las páginas en el orden mostrado y no queda protegido con contraseña.

## Requisitos

- macOS 26.5 o posterior.
- Xcode compatible con el SDK de macOS 26.5 para compilar el proyecto.

## Desarrollo

Abre [LazyPDF.xcodeproj](/Users/argorar/Documents/Github/lazy-pdf/LazyPDF.xcodeproj) en Xcode, selecciona el esquema **LazyPDF** y ejecuta la aplicación.

## Privacidad

Los archivos se procesan localmente en el equipo. Las contraseñas solo se mantienen en memoria durante la sesión para abrir y unir los documentos seleccionados.

## Licencia

Este proyecto se distribuye bajo la licencia [MIT](LICENSE).
