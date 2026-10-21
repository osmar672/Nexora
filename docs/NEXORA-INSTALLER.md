# Nexora Installer 0.2.0

## Qué es esta primera etapa

Nexora Installer es un asistente gráfico propio basado en los diálogos de KDE (`kdialog`). Permite aceptar el aviso de instalación, seleccionar toolsets y preparar una configuración JSON para Archinstall. La configuración preselecciona KDE Plasma, SDDM, PipeWire, NetworkManager, GRUB, `linux` y la zona horaria `America/Costa_Rica`.

**Limitación deliberada de esta etapa:** Archinstall sigue siendo el motor que particiona el disco, crea usuarios y copia el sistema. Por eso, al continuar se abre su flujo guiado en la terminal. No es todavía un instalador de disco 100 % gráfico escrito por Nexora. Delegar esas operaciones delicadas en una herramienta mantenida reduce el riesgo mientras se desarrolla y prueba la distribución.

## Uso

En la ISO live abre el menú de aplicaciones y elige **Instalar Nexora Linux**. También puedes ejecutarlo desde una terminal:

```bash
/usr/local/bin/nexora-installer
```

Marca los conjuntos opcionales que necesites. Después, en Archinstall, revisa el disco y el particionado, configura el usuario y la contraseña y lee todas las confirmaciones antes de aplicarlas. Elegir el disco incorrecto puede borrar sus datos.

## Qué se puede seleccionar

Los paquetes provienen de los manifiestos `toolsets/*.txt`: desarrollo/DevOps, seguridad web, redes, forense, ingeniería inversa y redes inalámbricas. Se combinan y deduplican antes de generar el JSON temporal. La lista base de KDE se configura con el perfil `desktop/plasma` de Archinstall.

## Siguiente paso para un instalador totalmente gráfico

Antes de sustituir Archinstall se necesita definir, construir e integrar un motor gráfico completo de instalación, configurar sus módulos de particionado/usuarios/bootloader y probar instalaciones UEFI, BIOS cuando se soporte, cifrado, diferentes sistemas de archivos y errores recuperables. Calamares es un candidato posible, pero su paquete para Arch se distribuye en AUR, así que no se debe declarar funcional en una ISO hasta construirlo e integrarlo de forma reproducible.
