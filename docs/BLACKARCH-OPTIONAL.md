# BlackArch opcional

BlackArch es un repositorio no oficial compatible con Arch y anuncia más de 2.800 herramientas. No recomendamos empaquetarlas todas en la ISO base de Nexora. La documentación oficial de BlackArch advierte que la ISO Full tiene un tamaño muy grande y desaconseja la instalación Full a la mayoría de usuarios debido a posibles errores/conflictos; recomienda escoger una selección de herramientas.

Página oficial: https://www.blackarch.org/downloads.html
Repositorio de código oficial: https://github.com/BlackArch/blackarch

Si decides habilitarlo en una instalación de Nexora, sigue la sección **Installing on top of ArchLinux** de la página oficial, descarga `strap.sh` desde `https://blackarch.org/strap.sh` y verifica su suma de comprobación usando el valor publicado actualmente en la web oficial antes de ejecutarlo como root. No ejecutes un script descargado sin comprobar origen e integridad. Después revisa las categorías disponibles y agrega solo las que necesites.

No se habilita BlackArch automáticamente al construir la ISO; es una elección explícita para quien administre el sistema. Tener acceso al repositorio permite seleccionar herramientas, pero no significa que todas estén instaladas ni que todas sean necesarias.
