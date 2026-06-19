Preguntas sobre el TP — De server-noob a arquitectura en capas
Las siguientes preguntas evalúan la comprensión del recorrido completo del proyecto: desde server-noob.js (V1), pasando por server-noob-mejorada.js (V2), hasta server.js con capas (V3) y la clase DbPg (V4).

V1 — server-noob.js
1. En server-noob.js, cada endpoint crea un new Client(config), hace await client.connect(), ejecuta la query, y en el finally hace await client.end(). Explicá con tus palabras qué problema de performance tiene este enfoque cuando la API recibe muchos requests simultáneos.

En server-noob.js, cada vez que llega un request se crea un cliente nuevo, se abre una conexión con PostgreSQL, se ejecuta la consulta y luego se cierra la conexión. El problema es que abrir y cerrar conexiones constantemente consume tiempo y recursos tanto del servidor como de la base de datos. Cuando la API recibe muchos requests simultáneos, tiene que repetir ese proceso para cada uno de ellos, lo que genera una pérdida de rendimiento. Además, PostgreSQL tiene un límite de conexiones concurrentes, por lo que una gran cantidad de usuarios podría provocar lentitud o incluso impedir que se acepten nuevas conexiones. Por eso este enfoque no escala bien cuando la aplicación crece. 


2. ¿Qué pasa si PostgreSQL está apagado y un request llega a server-noob.js? El client.connect() falla, y después se ejecuta el finally con await client.end(). ¿Qué error puede ocurrir y por qué?

Si PostgreSQL está apagado, la instrucción client.connect() va a lanzar un error porque no puede establecer la conexión con la base de datos. Después de eso, el bloque finally se ejecuta igual y se intenta hacer await client.end(). Como la conexión nunca llegó a completarse correctamente, puede producirse un segundo error al intentar cerrar un cliente que no está conectado. Esto sucede porque client.end() supone que existe una conexión válida para cerrar, pero en este caso la conexión falló antes de llegar a crearse.

3. En server-noob.js, si un compañero te dice "el endpoint de crear alumno tiene un bug", tenés que buscarlo en un archivo de ~215 líneas. ¿Por qué esto se vuelve un problema más grave a medida que la aplicación crece? Mencioná también qué pasa con Git cuando dos personas trabajan en el mismo archivo.

Tener todos los endpoints en un único archivo de aproximadamente 215 líneas ya resulta incómodo, pero el problema se vuelve mucho más grave a medida que la aplicación crece. Cada nueva funcionalidad agrega más código al mismo archivo, lo que dificulta encontrar errores, entender el funcionamiento de cada parte y realizar modificaciones sin afectar otras secciones. Si un compañero dice que el endpoint de crear alumnos tiene un bug, primero hay que localizarlo dentro de un archivo cada vez más grande y complejo. Además, cuando varias personas trabajan sobre el mismo archivo al mismo tiempo, Git suele generar conflictos durante los merges porque distintos desarrolladores modifican las mismas zonas del código. Esto hace que el trabajo en equipo sea más difícil y aumenta el riesgo de cometer errores.


4. Las queries en server-noob.js usan parámetros posicionales ($1, $2, etc.) en vez de concatenar strings. ¿Qué vulnerabilidad se previene con esto y por qué es importante?

El uso de parámetros posicionales como $1, $2, etc., evita la vulnerabilidad conocida como SQL Injection. Si las consultas se construyeran concatenando strings, un usuario malintencionado podría ingresar texto que fuera interpretado como parte del código SQL y modificar el comportamiento de la consulta. En cambio, cuando se utilizan parámetros, PostgreSQL recibe la consulta y los datos por separado, por lo que los valores ingresados por el usuario son tratados únicamente como datos y no como instrucciones SQL. Esto es muy importante porque protege la base de datos frente a accesos indebidos, modificaciones no autorizadas y posibles pérdidas de información.


V2 — server-noob-mejorada.js
5. En la versión mejorada se reemplazó Client por Pool. Explicá la diferencia entre ambos: ¿cómo maneja las conexiones cada uno? ¿Cuándo conviene usar Client y cuándo Pool?

La diferencia entre Client y Pool está en la forma en que manejan las conexiones con la base de datos. Client utiliza una única conexión, que se debe abrir cuando se necesita realizar una consulta y cerrar cuando termina de usarse. Es una opción más simple y suele ser útil en aplicaciones pequeñas, pruebas o scripts que realizan pocas operaciones. En cambio, Pool administra un conjunto de conexiones que permanecen disponibles y se reutilizan cada vez que la aplicación necesita acceder a la base de datos. De esta manera, evita crear y cerrar conexiones constantemente, mejora el rendimiento y resulta más adecuado para aplicaciones web donde varios usuarios pueden realizar consultas al mismo tiempo.


6. ¿Qué es un Router de Express y qué problema resuelve en esta versión? ¿Por qué las rutas dentro del router no incluyen /api/alumnos y solo definen '' o '/:id'?

Un Router de Express es una herramienta que permite separar y organizar las rutas de una aplicación en distintos archivos. Su principal objetivo es resolver el problema de tener todas las rutas juntas en un mismo archivo, lo que puede hacer que el código sea difícil de leer y mantener a medida que la aplicación crece. En esta versión se creó un router específico para los alumnos, logrando una mejor organización del proyecto. Las rutas dentro del router no incluyen /api/alumnos porque esa ruta principal se establece en el archivo del servidor al vincular el router con la aplicación. Por ese motivo, dentro del archivo del router solamente se definen las rutas relativas, como '' para obtener todos los alumnos o /:id para trabajar con un alumno específico, y Express se encarga de combinar ambas partes para formar la ruta completa.


7. En server-noob-mejorada.js, el archivo principal tiene solo ~26 líneas. ¿Qué responsabilidad tiene ese archivo ahora? ¿Dónde está la lógica de los endpoints?

En la versión mejorada, el archivo server-noob-mejorada.js tiene la responsabilidad de ser el punto de entrada de la aplicación y encargarse únicamente de la configuración general del servidor. En este archivo se crea la aplicación de Express, se configuran los middlewares necesarios, se vinculan los routers con sus rutas base y se inicia el servidor para que pueda escuchar las solicitudes. A diferencia de la versión anterior, ya no contiene la lógica de los endpoints, ya que esta fue trasladada a archivos de rutas específicos, como el router de alumnos, donde se define qué acciones se realizan ante cada petición (obtener, crear, modificar o eliminar datos). Esta separación de responsabilidades permite que el código sea más ordenado, reutilizable y fácil de mantener y ampliar a futuro.


8. En la versión mejorada desaparece el bloque finally. ¿Por qué ya no es necesario cerrar la conexión manualmente al usar Pool?

En la versión mejorada desaparece el bloque finally porque al utilizar Pool ya no es necesario abrir y cerrar una conexión manualmente después de cada consulta. A diferencia de Client, que suele requerir cerrar la conexión para liberar recursos, Pool crea y administra un conjunto de conexiones que permanecen abiertas y disponibles para ser reutilizadas por distintas consultas. Cuando una operación termina, la conexión vuelve al conjunto de conexiones disponibles en lugar de cerrarse. De esta manera, Pool se encarga automáticamente de la administración de las conexiones, reduce la cantidad de conexiones creadas y destruidas y mejora tanto el rendimiento como la eficiencia de la aplicación.


V3 — server.js (arquitectura en capas)
9. Nombrá las tres capas de la arquitectura y explicá con tus palabras qué responsabilidad tiene cada una. ¿Cuál conoce los req y res de Express? ¿Cuál conoce el SQL? ¿Cuál tiene las reglas de negocio?
La arquitectura está dividida en tres capas: controller, service y repository. La capa controller es la que se comunica directamente con Express, por lo que conoce los objetos req y res y se encarga de recibir las solicitudes HTTP y enviar las respuestas correspondientes. La capa service contiene la lógica de negocio de la aplicación, es decir, las reglas y validaciones necesarias antes de realizar una operación, además de coordinar la comunicación entre distintos servicios. Por último, la capa repository es la encargada de acceder a la base de datos y ejecutar las consultas SQL. Esta separación permite que cada capa tenga una responsabilidad específica, logrando un código más organizado, mantenible y fácil de modificar.


10. En alumnos-service.js, la edad del alumno se calcula en el service con una función JavaScript, en vez de calcularla en la query SQL. ¿Por qué se eligió calcularla en el service y no en la base de datos?

La edad del alumno se calcula dentro del service utilizando una función de JavaScript porque el cálculo de la edad forma parte de la lógica de negocio de la aplicación y no de la responsabilidad de la base de datos. De esta manera, se mantiene el SQL más simple y la lógica queda centralizada en la capa de service, permitiendo reutilizar el cálculo en otros lugares y facilitando cambios futuros sin tener que modificar las consultas de la base de datos.


11. Cuando se crea un alumno con un id_curso que no existe, AlumnosService llama a CursosService para verificarlo. ¿Por qué llama al service de cursos y no directamente al repository de cursos?

Cuando se crea un alumno con un id_curso, AlumnosService llama a CursosService y no directamente al repository de cursos porque debe respetar la separación de responsabilidades entre las capas. El service de cursos es quien conoce las reglas de negocio relacionadas con los cursos y puede realizar las validaciones necesarias antes de acceder a los datos. Si AlumnosService llamara directamente al repository, estaría saltando la capa de negocio de cursos, generando un mayor acoplamiento entre componentes y dificultando el mantenimiento del código.


12. ¿Para qué sirve el archivo .env y la librería dotenv? ¿Qué problema de las versiones anteriores resuelve? ¿Por qué el archivo .env no se sube al repositorio de Git?

El archivo .env se utiliza para guardar variables de configuración de la aplicación, como los datos de conexión a la base de datos, puertos o credenciales. La librería dotenv se encarga de leer ese archivo y cargar esas variables en la aplicación para que puedan utilizarse desde el código. Esto resuelve el problema de las versiones anteriores donde la configuración estaba escrita directamente en el código (hardcodeada), haciendo más difícil cambiar de entorno y exponiendo información sensible. El archivo .env no se sube al repositorio de Git porque contiene datos privados o específicos de cada entorno, como usuarios, contraseñas o configuraciones que no deben ser compartidas públicamente.


13. ¿Qué hace LogHelper y por qué es mejor que usar console.log(error) suelto en cada lugar del código?

LogHelper es una utilidad centralizada encargada de manejar el registro de errores y mensajes de la aplicación. Es mejor que escribir console.log(error) en diferentes partes del código porque permite mantener un formato consistente en todos los logs, evitar la repetición de código y facilitar futuras mejoras, como guardar los errores en archivos, enviar alertas o agregar más información útil como fechas, niveles de gravedad o el origen del error. De esta manera, el manejo de logs queda más organizado y profesional.

V4 — DbPg y DbMssql
14. Mirá alumnos-repository.js (versión original) y alumnos-repository-new.js (versión refactorizada). ¿Qué código repetido (boilerplate) se eliminó al extraer la clase DbPg? Mencioná al menos 3 cosas que ya no aparecen en el repository nuevo.

Al extraer la clase DbPg se eliminó del repository mucho código repetido o boilerplate relacionado con la conexión y ejecución de consultas a la base de datos. En la versión nueva ya no aparecen la creación de la conexión a la base de datos, la llamada al método para ejecutar las consultas (query), el manejo repetido de los resultados como rows y rowCount, ni los bloques de manejo de errores y cierre de conexiones. Todo ese trabajo queda centralizado dentro de DbPg, por lo que el repository queda más simple y se dedica únicamente a definir las consultas SQL y llamar al método correspondiente.


15. La clase DbPg tiene 4 métodos: queryAll, queryOne, queryReturnId y queryRowCount. ¿Qué devuelve cada uno y en qué tipo de operación SQL se usa cada uno?

La clase DdPg tiene cuatro métodos que permiten realizar distintos tipos de consultas de manera más sencilla. QueryAll devuelve una colección de registros y se utiliza en consultas SELECT que pueden traer varios resultados, como obtener la lista de todos los alumnos. queryOne devuelve un único registro y se usa en consultas SELECT donde se espera obtener un solo resultado, por ejemplo buscar un alumno por su ID. QueryReturnId devuelve el identificador del registro recién creado y se utiliza principalmente en operaciones INSERT. Por último, query RowCount devuelve la cantidad de filas afectadas por una operación y se utiliza generalmente en consultas UPDATE y DELETE para verificar cuántos registros fueron modificados o eliminados.


16. En los repositories nuevos, la clase se importa como import Db from './db-pg.js' (con el nombre Db, no DbPg). ¿Por qué se usa ese nombre genérico? ¿Qué pasa si mañana querés cambiar de PostgreSQL a SQL Server — cuántas líneas del repository tenés que modificar?

En los nuevos repositorios se importa la clase como Db y no como DdPg porque se busca que el código no dependa de un motor de base de datos específico. El nombre genérico permite que el repository trabaje con una abstracción de acceso a datos, sin importar si internamente se utiliza PostgreSQL, SQL Server u otro sistema. Si en el futuro se quiere cambiar de PostgreSQL a SQL Server, no sería necesario modificar la lógica del repository; únicamente habría que cambiar la línea de importación para utilizar la nueva clase de base de datos, es decir, solo se modificaría una línea en cada repository.


"¿Dónde lo pondrías?" — Situaciones prácticas
En cada situación, indicá en qué capa lo pondrías (controller, service o repository) y explicá por qué.

17. Necesitás agregar un nuevo endpoint GET /api/alumnos/curso/:idCurso que devuelva todos los alumnos de un curso. La query sería SELECT * FROM alumnos WHERE id_curso = $1. ¿Dónde pondrías esa query? ¿Dónde pondrías la ruta del endpoint? ¿Agregarías algo en el service?

La pondria en el “repository”, porque esa capa es la encargada de comunicarse con la base de datos y escribir las consultas SQL. La ruta del endpoint GET /api/alumnos/curso/:idCurso se agregaría en el controller o router, porque es la capa que conoce las rutas de Express y los objetos req y res. También agregaría un método en el service, ya que esta capa se encarga de la lógica de negocio y funciona como intermediaria entre el controller y el repository. Aunque en este caso solo llame al repository, mantiene la arquitectura ordenada y permite agregar validaciones o reglas en el futuro.

18. El cliente pide que al crear un alumno, si no se manda fecha_nacimiento, el sistema ponga la fecha de hoy por defecto. ¿En qué capa pondrías esa lógica y por qué? ¿Es una regla de negocio o es algo de la base de datos?

La lógica de asignar la fecha actual cuando no se envía fecha_nacimiento debería ir en la capa service, porque se trata de una regla de negocio de la aplicación y no de una responsabilidad de la base de datos. De esta forma la regla queda centralizada en el código de la aplicación, es más fácil de modificar y no depende del motor de base de datos utilizado.

19. Necesitás que al eliminar un curso, se verifique primero que no tenga alumnos asociados, y si tiene, devolver un error 400 con el mensaje "No se puede eliminar el curso porque tiene alumnos asociados". ¿Dónde pondrías la verificación (la consulta de si tiene alumnos)? ¿Dónde pondrías el throw new Error(...)? ¿Y dónde se atraparía ese error para devolver el 400?

La consulta para verificar si un curso tiene alumnos asociados se realizaría en el repository, porque implica acceder a la base de datos y ejecutar una consulta SQL. La decisión de no permitir eliminar un curso si tiene alumnos y el throw new Error("No se puede eliminar el curso porque tiene alumnos asociados") se colocarían en el service, ya que forman parte de las reglas de negocio. Luego ese error sería atrapado en el controller, que se encarga de transformar el error en una respuesta HTTP, en este caso devolviendo un código 400 con el mensaje correspondiente. 

20. Te piden agregar un endpoint que devuelva un resumen por curso: nombre del curso, cantidad de alumnos, y el promedio de edad de esos alumnos. ¿Qué parte resolvés con SQL (en el repository) y qué parte resolvés con lógica (en el service)? ¿O se puede resolver todo en una sola capa?

La parte de obtener los datos desde la base de datos se resolvería en el repository mediante consultas SQL, por ejemplo utilizando JOIN, COUNT y otras funciones de agregación para obtener el nombre del curso y la cantidad de alumnos. La capa service se utilizaría para aplicar cualquier lógica adicional sobre esos datos, como cálculos o transformaciones que correspondan a las reglas de negocio. En algunos casos se podría resolver todo con una sola consulta SQL dentro del repository, por ejemplo calculando también el promedio de edad, pero es importante mantener la separación de responsabilidades: el acceso y las consultas a los datos pertenecen al repository, mientras que las reglas de negocio y las transformaciones propias de la aplicación pertenecen al service.

