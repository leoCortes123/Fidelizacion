Cambios para el diseño general de la plataforma:
RECUERDA QUE LA PLATAFORMA ESTA PENSADA PARA MANIPULARSE DESDE UN NAVEGADOR EN UN TELEFONO ASI QUE EL DISEÑO RESPONSIVO DEBE ESTAR BIEN DISEÑADO
-El nombre de la aplicacion es Loopoint, 
-La seccion del menu y del contenido de la pagina deben ser separados y el menu debe estar fijo y no ser escroleable con la seccion de contenido
-Configura la barra superior para ocultarse automaticamente cuando se de scroll hac9ia abajo y aparecer con el scroll opuesto
-Elimina el boton de cerar sesion y deja un menu desplegable con la opcion cerrar sesion y cambiar a modo oscuro
-En los formularios o campos que se deban llenar agrega un tooltip con una descripcion corta para guiar a un usuario sin conocimiento de la aplicación
-Define que parametros debe cumplir un cliente para ser cliente frecuente, añade la configuracion de parametros a la configuracion del negocio
-Cuando se cambia de pestaña y volver a la aplicación esta se recarga y borra los datos de los formularios que se esten llenando, quiero que no se reinicie el formulario cuando vuelva a la pestaña o ventana 
-La aplicación debe tener dos paletas de colores una para el negocio y una para los clientes, conserva la del cliente y cambia la de admin
-Elimina el boton de ver portal de cliente
-en mobil agrega un boton flotante permanentemente en la parte inferior derecha como acceso rapido a la pantalla de registrar compra
-loopointCoinNoBG.png es el logo diseñado para la aplicacion, reemplazalo y reemplaza las referencias en el frente a puntos y cambialos por loopoints, asi se llama la moneda que se maneja en la aplicacion
-El cliente debe tener un NickName unico opcional, si no lo llena, automaticamente se creara con el nombre del usuario como nick con un numero consecutivo si el nombre ya esta en uso. 



A continuacion hay una lista de cambios y rediseño por pantalla u opcion de menu, dejare las pantallas en el orden que deben aparecer en el menu lateral de la plataforma o en el menu inferior en mobil

Pantallas de negocio


principal
-Elimina la pagina principal, dirige directamente al dashboard de cliente o de negocio

Dashboard
-Cambia el nombre de dashboard por Inicio y el diseño tiene que ser diferente para el cliente 
-para el negocio elimina las tarjetas gigentes y reemplazalas por una forma de mostrar estos datos mas condensada pero visible, abajo pon la generacion del qr por el valor de la compra, aquí se tiene que poder elegir entre introducir el valor manualmente y generar una compra seleccionando los productos de la carta asi que agrega un boton donde se despliegue la carta y se puedan seleccionar los productos y las cantidades de cada uno (incluyenbdo los combos) y al aceptar se colocara automaticamente el valor en el imput del valor. Ya con eso se puede generar el qr
-Agrega un boton para desplegar el qr de invitacion por si se necesita mostrar el qr a un cliente sin que haga una compra
-para el negocio elimina las tarjetas gigentes y reemplazalas por una forma de mostrar estos datos mas condensada pero visible, abajo pon la generacion del qr por el valor de la compra, aquí se tiene que poder elegir entre introducir el valor manualmente y generar una compra seleccionando los productos de la carta asi que agrega un boton donde se despliegue la carta y se puedan seleccionar los productos y las cantidades de cada uno (incluyenbdo los combos) y al aceptar se colocara automaticamente el valor en el imput del valor. Ya con eso se puede generar el qr



Configuracion
-Como segunda opcion debe aparecer configuracion que va a ser la misma configuracion inicial, Completa esta pantalla y sus pestañas para que no sea necesario usar las pantallas individuales 
-Modifica el diseño para que funcione para telefonos, reduce el tamaño de los titulos, el mensaje de borrador o parecido eliminalo o dejalo como una notificacion interna de la pagina, reduce y ordena los elementos para que sean facilmente configurables en un telefono
-para el negocio elimina las tarjetas gigentes y reemplazalas por una forma de mostrar estos datos mas condensada pero visible, abajo pon la generacion del qr por el valor de la compra, aquí se tiene que poder elegir entre introducir el valor manualmente y generar una compra seleccionando los productos de la carta asi que agrega un boton donde se despliegue la carta y se puedan seleccionar los productos y las cantidades de cada uno (incluyenbdo los combos) y al aceptar se colocara automaticamente el valor en el imput del valor. Ya con eso se puede generar el qr
-Para datos de negocio haz mas completo el formulario, recopila datos como la direccion, barrio, telefono de whatsapp y lo que creas relevante
-agrega la opcion de cargar una foto, por el momento esta foto se guardara en el servidor, cuando sea adecuado busco un servicio para guardarlas 
-Para las otras 2 pestañas no hay cambios pero enfocate en hacer mas comoda la experiencia desde el telefono
-Agrega una pestaña para configurar las recompensas 



Campañas
-Esta bien pero quiero que agregues algunas campañas estaticas que se pueden habilitar o deshabilitar dependioendo de la eleccion del negocio, por ejemplo cumpleaños del cliente, primera compra, aniversario de suscripcion del cliente, aniversario de primera compra y recuperacion de cliente (recompensa a un cliente frecuente que volvio despues de un tiempo determinado)

Solicitudes
-Las formas de redimir los premios son: 1. Por solicitud manual (el usuario selecciona redimir un premio en su cuenta y aparece en esta vista para aprobar). 2. el cliente redime con qr desde su plataforma, alli se genera el qr y el negocio escanea el qr que lo redirigira a una pantalla donde se aprobara la redencion de los loopoints, se mostrara una confirmacion de redencion y al aceptar se redirigira de nuevo a la ventana de registrar compra 


Auditoria 
-dejala mas clara para que el admin la pueda leer y entender

Clientes
Elimina la opcion de redimir y aplica la visualizacion del detalle de la compra 

Compras
Agrega el detalle para ver la compra, en caso de que se hayan registrado los productos del menu 


Pantallas de cliente
Elimina la pantalla de balance

Inicio
-Un cliente puede estar inscrito a varios negocios asi que los loopoints deben manejarse por negocio asi que como pagina principal de clientes debe verse una lista de los negocios a los cuales esta inscrito el cliente con el numero de puntos y en verde si hay recompensas por reclamar
-Al seleccionar un negocio se podra ver una pantalla como la que ve customer como principal y enn lugar del saludo en la parte superior debe estar una lista de negocios a los que esta incrito el cliente

Compras
-La lista de las compras registradas y el detalle

Canjes
-Lista de los canjes realizados
