# Decisiones técnicas — OrbitRooms

Bitácora de decisiones de arquitectura. Se agrega una entrada nueva cada vez
que se resuelve un "por qué elegimos X y no Y". No se edita el historial, solo
se agrega al final. Si una decisión se revierte, se agrega una entrada nueva
que lo diga (no se borra la anterior).

---

## 2026-05-20 — Persistencia local: Drift sobre SQLite

**Contexto:** OrbitRooms necesita guardar datos localmente, funcionar
offline, tener relaciones entre entidades, hacer consultas y poder escalar.

**Decisión:** usar `drift` como capa sobre SQLite, en vez de usar el paquete
`sqlite3` puro.

**Por qué:** escribir SQL crudo a mano en Flutter es incómodo y frágil a
medida que crece el número de tablas y relaciones. Drift da tipado, queries
generadas y migraciones manejables sin perder el control de estar sobre
SQLite real (no es un ORM pesado tipo Hive/Isar con su propio modelo).

---

## 2026-05-20 — No usar `sqlite3_flutter_libs`

**Contexto:** la mayoría de tutoriales de Drift instalan `drift` +
`sqlite3_flutter_libs` + `path_provider` + `path`.

**Decisión:** **no** incluir `sqlite3_flutter_libs`.

**Por qué:** ese paquete existía para empaquetar el motor nativo de SQLite
(`package:sqlite3` v2.x) dentro de la app. Su propio changelog advierte que
queda obsoleto al adoptar `sqlite3` v3.x, que ya resuelve eso internamente.
Las versiones modernas de `drift` (`^2.33.0`) ya gestionan un `sqlite3`
moderno sin necesitar ese paquete extra.

**Alternativas consideradas:** instalarlo "por si acaso" — descartado porque
agrega una dependencia obsoleta con mantenimiento futuro incierto, sin
beneficio real hoy.

**Estado:** vigente. Revisar si en el futuro Drift cambia su forma de
resolver el motor nativo (por ejemplo, al pasar a `drift_flutter` si se
adopta ese paquete de conveniencia).

---

## 2026-05-20 — Riverpod se pospone

**Contexto:** duda sobre si instalar Riverpod junto con la base de datos.

**Decisión:** no instalar Riverpod todavía.

**Por qué:** Riverpod resuelve manejo de estado y reactividad, pero hoy no
existe nada real que administrar (no hay datos, repositories ni casos de
uso). Meterlo ahora sería complejidad prematura y dificultaría entender qué
problema resuelve cada pieza. Se agregará cuando exista el primer caso de uso
real (ej. `GetPropertiesUseCase`) que la UI necesite consumir con
loading/error/data.

**Estado:** vigente. Revertir esta decisión cuando se llegue al paso 8 del
roadmap en [CLAUDE.md](../CLAUDE.md).

---

## 2026-05-20 — Ubicación de la base de datos: `core/database`

**Contexto:** decidir si la base de datos vive dentro de una feature
específica o en una carpeta compartida.

**Decisión:** vive en `core/database`, no dentro de `features/*`.

**Por qué:** la base de datos es transversal a toda la app (properties,
rooms, reservations, etc. la comparten), no pertenece a una sola feature.

**Estado:** vigente.

---

## 2026-05-21 — Multi-propiedad desde el modelo de datos

**Contexto:** al definir el PRD surgió el caso real: una administradora tiene
su propio hostal (propiedad principal) pero además puede administrar otras
casas/propiedades que no le pertenecen (de terceros que le piden gestionarlas).

**Decisión:** `Property` es una entidad de la que puede existir más de una
por instalación, desde el día uno del modelo de datos (no se agrega "por si
acaso" — ya hay un caso de uso real que lo pide). Cada `Room` pertenece a
exactamente una `Property`.

**Por qué:** el caso de uso ya existe hoy (no es una hipótesis a futuro), y
diseñar el modelo asumiendo "una sola propiedad" obligaría a una migración
de esquema dolorosa apenas apareciera el segundo hostal.

**Estado:** vigente. Detalle funcional en [PRD.md](PRD.md).

---

## 2026-05-21 — Un solo usuario ahora, pero IDs listos para sync futura

**Contexto:** hoy la app es de un solo usuario sin login (no hay necesidad
real de roles/autenticación todavía). Pero a futuro se planea que la app
pueda sincronizar con un servidor (offline-first que eventualmente también
sea online), y quizás soportar empleados con roles.

**Decisión:** no se construye autenticación, roles ni sync ahora. Pero las
tablas usarán **UUID como primary key** (no enteros autoincrementales) desde
la primera tabla que se cree.

**Por qué:** agregar roles/auth/sync hoy sería complejidad prematura (no hay
nada que sincronizar todavía). Pero cambiar de ID autoincremental a UUID
*después* de tener datos reales de usuarios en producción es una migración
grande y riesgosa (los IDs autoincrementales chocan entre dispositivos al
sincronizar; los UUID no). Usar UUID desde el inicio no cuesta nada extra
hoy y evita atarnos innecesariamente, tal como se pidió explícitamente.

**Estado:** vigente. Aplica desde la primera tabla Drift que se escriba.

---

## 2026-05-21 — Pagos básicos sí entran en el MVP

**Contexto:** decidir si el registro de pagos de una reserva es parte del
alcance inicial o se pospone.

**Decisión:** sí, el MVP registra pago por reserva: monto, método de pago y
estado (pagado / pendiente / parcial).

**Por qué:** saber si una reserva está pagada es información central para
administrar un hostal, no es un "extra" — dejarlo fuera haría el MVP
incompleto para el uso real diario.

**Estado:** vigente. Detalle funcional en [PRD.md](PRD.md).

---

## 2026-05-21 — Dueño real de una propiedad: texto simple, no entidad

**Contexto:** cuando la administradora gestiona una propiedad de un tercero,
¿el dueño real debe ser un campo de texto libre en `Property` o una entidad
`Owner` propia con contacto estructurado? (Pregunta abierta #1 del PRD.)

**Decisión:** campo de texto libre en `Property` (`ownerName`,
`ownerContact`), sin tabla `Owner` separada.

**Por qué:** hoy no existe ningún requerimiento funcional que dependa de que
el dueño sea una entidad (no hay reportes por dueño, no hay portal ni login
de dueño). Crear la entidad ahora sería estructura para un caso de uso que
no existe todavía. Migrar de texto a entidad más adelante, si aparece esa
necesidad real, es barato; lo inverso no lo es.

**Estado:** vigente. Aplica al diseño de la tabla `Property`.

---

## 2026-05-21 — Tipo de habitación: entidad `RoomType` personalizable, no enum

**Contexto:** ¿el tipo de una habitación (individual, doble, dormitorio
compartido...) debe ser una lista fija definida por la app, texto libre, o
algo intermedio? (Pregunta abierta #2 del PRD.)

**Decisión:** entidad `RoomType` mínima (un solo campo relevante: `nombre`),
que el usuario crea y reutiliza libremente. No viene precargada por la app,
no es un enum cerrado.

**Por qué:** un enum fijo definido por nosotros no calza con la diversidad
real de propiedades que un mismo usuario puede administrar (confirmado en la
decisión de multi-propiedad). Texto libre sin restricciones genera
inconsistencias ("Doble" vs "doble" vs "Dobles") que rompen el reporte de
ocupación por tipo (sección 5.8 del PRD), que sí es un requerimiento real.
Una tabla mínima da lo mejor de ambos: flexibilidad real sin duplicar
etiquetas por errores de tipeo, al costo de una tabla con un solo campo.

**Estado:** vigente. Aplica al diseño de las tablas `RoomType` y `Room`
(`Room.roomTypeId` como FK).

---

## 2026-05-21 — Precio por persona, dos tarifas, sin descuento automático

**Contexto:** el precio real de una habitación no es fijo: cambia entre
semana ($12) y fin de semana ($15), y se cobra **por persona**, no por
habitación. Además a veces se aplica un descuento por niños, pero no según
una regla fija — es una decisión caso a caso de la administradora. (Pregunta
abierta #3 del PRD.)

**Decisión:**
- `Room` tiene dos tarifas por persona: `ratePerPersonWeekday` y
  `ratePerPersonWeekend` (no una lista de 7 tarifas por día).
- "Fin de semana" = viernes, sábado y domingo.
- `Reservation` calcula un precio sugerido = Σ (tarifa del día × cantidad de
  personas) por cada noche de la estadía, pero el precio final queda como un
  campo editable, no forzado al valor calculado.
- No se modela un "descuento de niño" ni un campo de conteo de niños: no
  existe una regla fija que aplicar (a veces sí, a veces no, a discreción de
  la administradora).

**Por qué:** dos tarifas cubren el caso real descrito hoy sin construir
estructura para un caso (tarifas por día individual) que no existe todavía.
Hacer el precio final editable evita programar una "regla de descuento"
sobre una práctica que el propio usuario describe como inconsistente —
intentar formalizarla generaría una función que no refleja cómo se decide
en la realidad, y quedaría desactualizada apenas cambie el criterio.

**Estado:** vigente. Aplica a las tablas `Room` (tarifas) y `Reservation`
(campo de precio final editable + cantidad de personas).

---

## 2026-05-21 — Una sola moneda global, sin conversión

**Contexto:** ¿la moneda es un valor fijo para toda la app, o cada propiedad
puede tener la suya? (Pregunta abierta #4 del PRD.)

**Decisión:** una sola moneda, configurada una vez a nivel de la app entera
(no por propiedad). Sin lógica de conversión entre monedas.

**Por qué:** no hay ningún caso real hoy de administrar propiedades en
países o monedas distintas — el escenario descrito es siempre la misma
administradora, mismo entorno. Agregar el campo por propiedad ahora sería
estructura para una necesidad hipotética. Si aparece ese caso real más
adelante, agregar un campo de moneda a `Property` no rompe nada existente.

**Estado:** vigente. Se necesita un lugar mínimo para guardar esta
configuración global (una fila de ajustes, no una tabla por propiedad) —
se define al implementar `core/database`.

---

## 2026-05-21 — Reservation es un grupo de habitaciones, no una habitación

**Contexto:** el caso real (confirmado por el usuario) es que un grupo grande
(ej. 20 personas) se reparte en 2-3 habitaciones según la capacidad
disponible en ese momento — no siempre en habitaciones fijas ni con la misma
cantidad de personas cada una. Además, la capacidad "oficial" de una
habitación es orientativa: si dicen "somos 8" en un cuarto pensado para 4, se
les acomoda igual y se cobra por las 8 personas reales. (Pregunta abierta #5
del PRD.)

**Decisión:**
- `Reservation` deja de ser "1 habitación" y pasa a ser un **grupo de
  estadía**: huésped principal, fechas, estado, precio total (editable) y
  pagos — todo a nivel de grupo.
- Se agrega `ReservationRoom` como línea dentro de una `Reservation`: qué
  `Room` se asignó y cuántas personas de ese grupo van ahí. Una reserva de 1
  sola habitación simplemente tiene una única línea.
- `Room.capacity` pasa a ser **informativa**, no una validación que bloquee
  la asignación. La app no impide asignar más personas que la capacidad
  nominal.
- La regla de "no solapar fechas en la misma habitación" se aplica a nivel
  de `ReservationRoom` (por habitación), no a nivel de `Reservation`.
- `Payment` sigue atado a `Reservation` (el grupo), no a cada
  `ReservationRoom` — el grupo paga como uno.

**Por qué:** este no es un caso hipotético de familia ocasional — es cómo
opera el negocio regularmente en temporada alta. Modelar `Reservation` como
"1 habitación fija" habría obligado a una migración de esquema completa
apenas se necesitara registrar el primer grupo grande. Separar la asignación
de habitaciones (`ReservationRoom`) del grupo (`Reservation`) también
resuelve naturalmente el cálculo de precio (por persona, por habitación,
según tarifa entre-semana/fin-de-semana ya definida) sin necesitar lógica
especial para reservas de una sola habitación.

**Estado:** vigente. Es el cambio de modelo más grande hasta ahora — afecta
directamente el diseño de las tablas `Reservation`, `ReservationRoom`,
`Room` (capacidad) y `Payment` (FK a `Reservation`, no a `ReservationRoom`).

---

## 2026-05-21 — Reembolso = pago con monto negativo, sin entidad nueva

**Contexto:** ¿qué pasa con los pagos ya registrados cuando se cancela una
reserva? ¿hace falta una entidad de reembolso? (Pregunta abierta #6 del
PRD.)

**Decisión:** cancelar una reserva no borra ni modifica los pagos
existentes — quedan como historial. Si hay que devolver dinero, se registra
como un `Payment` más con **monto negativo** sobre la misma reserva. No se
crea una tabla `Refund` separada.

**Por qué:** `Payment` ya se suma para calcular el saldo de la reserva; un
monto negativo resuelve el reembolso sin agregar una entidad nueva ni
lógica especial. No hay evidencia de que los reembolsos sean lo bastante
frecuentes o complejos (ej. reembolsos parciales con motivo, aprobaciones)
como para justificar una estructura dedicada.

**Estado:** vigente. `Payment.amount` debe poder ser negativo (no forzar un
`CHECK amount > 0` en la tabla).

---

## 2026-05-21 — Check-in 14:00 / check-out 11:00, fechas sin hora, rango medio-abierto

**Contexto:** ¿existen horarios fijos de check-in/check-out, y cómo afecta
eso a cómo se guardan las fechas y se valida el solapamiento entre reservas?
(Pregunta abierta #7 del PRD.)

**Decisión:**
- Check-in 14:00, check-out 11:00, fijos y globales (no por propiedad).
- `Reservation.checkInDate`/`checkOutDate` se guardan como fecha, sin
  componente de hora — la hora es una regla de negocio conocida, no un dato
  variable por reserva.
- Se permite que una habitación tenga checkout de una reserva y check-in de
  otra el mismo día calendario (hay margen de limpieza entre 11:00 y
  14:00). La validación de solapamiento usa un rango medio-abierto
  `[checkInDate, checkOutDate)`.

**Por qué:** es la práctica estándar en hospedaje y evita bloquear
rotaciones válidas el mismo día, que son operativamente normales y
deseables (maximizan ocupación). Guardar fecha sin hora simplifica el
modelo porque la hora nunca varía por reserva.

**Estado:** vigente. Aplica a la validación de solapamiento en
`ReservationRoom` (sección 5.2/5.4/5.10 del PRD). Con esto, las 7 preguntas
abiertas iniciales del PRD quedan resueltas.

---

## 2026-05-21 — Dinero como entero (centavos), no `double`

**Contexto:** al escribir las tablas `Room` (tarifas), `Reservation`
(precio total) y `Payment` (montos), había que elegir el tipo de columna
para valores monetarios.

**Decisión:** todo monto se guarda como `IntColumn` en la unidad más pequeña
de la moneda ("centavos"), nunca como `double`/`real`. Los campos se nombran
con el sufijo `Cents` (`ratePerPersonWeekdayCents`, `totalPriceCents`,
`amountCents`, `subtotalCents`) para que el nombre deje explícito que no es
la unidad principal.

**Por qué:** los `double` en cualquier lenguaje (Dart incluido) no
representan exactamente la mayoría de valores decimales en base 10 — sumar
pagos parciales con `double` puede arrastrar errores de redondeo minúsculos
que, en una app de dinero real, no son aceptables. Enteros no tienen ese
problema. Es una decisión puramente técnica (no de producto), por eso no se
consultó como pregunta del PRD.

**Estado:** vigente. La capa de UI/dominio (cuando se construya) es
responsable de convertir centavos ↔ formato legible (ej. dividir por 100 al
mostrar, multiplicar por 100 al leer un input del usuario).

---

## 2026-05-21 — Primeras tablas creadas en `core/database/tables`

**Contexto:** con el PRD v1 cerrado, se tradujo el modelo de datos a tablas
Drift reales.

**Decisión:** se crearon, una por archivo:
`properties_table.dart`, `room_types_table.dart`, `rooms_table.dart`,
`guests_table.dart`, `reservations_table.dart`,
`reservation_rooms_table.dart`, `payments_table.dart` y
`app_settings_table.dart` (fila única con la moneda global). Todas usan UUID
como PK vía `clientDefault(() => const Uuid().v4())`. Los estados
(`ReservationStatus`, `PaymentMethod`) se mapean con `textEnum<T>()` de
Drift en vez de texto libre.

**Nota técnica:** `app_database.dart` debe importar `package:uuid/uuid.dart`
directamente aunque no lo use él mismo, porque `app_database.g.dart` es
`part of` esa librería y solo resuelve símbolos de sus propios imports, no
los de los archivos de tabla que importa transitivamente.

**Estado:** vigente. `AppDatabase` ya registra las 8 tablas y genera código
sin errores (`dart run build_runner build`).

---

## 2026-05-21 — Conexión real: `NativeDatabase` vía `LazyDatabase`, sin `sqlite3_flutter_libs`

**Contexto:** `AppDatabase` solo podía instanciarse con un `QueryExecutor`
inyectado (útil para tests), pero la app real necesita abrir un archivo
`.sqlite` en el almacenamiento del dispositivo.

**Decisión:** se agregó `AppDatabase.connect()`, un constructor con nombre
que abre `NativeDatabase.createInBackground(file)` dentro de un
`LazyDatabase` (para no tocar el disco hasta el primer uso real), ubicando
el archivo con `path_provider` (`getApplicationDocumentsDirectory`) +
`path`. Esto confirma en la práctica la decisión de no usar
`sqlite3_flutter_libs`: `package:sqlite3` (dependencia transitiva de
`drift`) ya resuelve el motor nativo en cada plataforma sin ese paquete
extra.

**Por qué `LazyDatabase`:** evita crear/abrir el archivo en el momento de
construir `AppDatabase()` (por ejemplo, durante tests o arranque de la app
antes de necesitarlo), difiriéndolo hasta la primera consulta real.

**Gotcha real encontrado al escribir la prueba:** `db.into(tabla).insert()`
devuelve el **rowid entero interno de SQLite**, no el UUID que declaramos
como primary key. Si se necesita el ID inmediatamente después de insertar
(ej. para usarlo como FK en la misma operación, como `Room.propertyId`), hay
que generar el UUID **antes** del insert y pasarlo explícito en el
`Companion` (`PropertiesCompanion.insert(id: Value(uuid), ...)`), en vez de
confiar en el valor de retorno.

**Estado:** vigente. Validado con
[app_database_test.dart](../test/core/database/app_database_test.dart):
inserta y lee una `Property`/`Room`, y una `Reservation` con dos `Payment`
(uno negativo, simulando un reembolso) cuyo saldo se calcula correctamente.

---

## 2026-05-21 — Falta `isActive` en `Properties` (corregido antes de usarlo)

**Contexto:** al empezar a escribir `PropertyRepository` se necesitaba un
método para "desactivar" una propiedad (PRD 5.1 lo pide explícitamente),
pero la tabla `Properties` no tenía columna `isActive` — se me pasó al
crearla, a pesar de que sí se agregó en `Rooms`.

**Decisión:** se agregó `BoolColumn isActive` (default `true`) a
`Properties`, igual que en `Rooms`. Como todavía no hay datos reales en
ningún dispositivo (`schemaVersion` sigue en 1), se corrigió la tabla
directamente en vez de escribir una migración.

**Por qué:** es un recordatorio de que el PRD es la fuente de verdad al
traducir a tablas — "desactivar" en la sección 5.1 debía mapear a la misma
convención de soft-delete que ya se usó en `Rooms`, y no se hizo la primera
vez.

**Estado:** vigente.

---

## 2026-05-21 — `PRAGMA foreign_keys = ON`

**Contexto:** SQLite no valida claves foráneas por defecto — hay que
activarlo explícitamente por conexión. Sin esto, borrar una `Property` con
`Room`s asociados, o un `Guest` con `Reservation`s, dejaría filas huérfanas
sin ningún aviso.

**Decisión:** `AppDatabase` activa `PRAGMA foreign_keys = ON;` en
`migration.beforeOpen`, para cualquier conexión (real o de test).

**Por qué:** es la única forma de que las referencias (`Room.propertyId`,
`Reservation.guestId`, etc.) realmente protejan contra borrados que
rompan la integridad de los datos — necesario ahora que los repositories
empiezan a borrar filas.

**Estado:** vigente. Consecuencia práctica: borrar un `Guest` con
reservas, o desactivar en vez de borrar una `Property`/`Room` en uso,
lanza una excepción de SQLite en vez de corromper datos silenciosamente.

---

## 2026-05-21 — Repositories: sin interfaz de dominio todavía, sin modelos propios

**Contexto:** al construir la capa de repositories (`PropertyRepository`,
`RoomRepository`, `RoomTypeRepository`, `GuestRepository`,
`ReservationRepository`, `PaymentRepository`, `AppSettingsRepository`) había
que decidir dos cosas de forma (Clean Architecture clásica sugiere ambas):
¿el repository implementa una interfaz definida en `domain`? ¿se mapean las
filas de Drift a entidades de dominio propias, o se usan las clases que
Drift ya genera (`Property`, `Room`, `Reservation`, etc.)?

**Decisión:** por ahora, **no** a las dos. Los repositories son clases
concretas (sin interfaz en `domain`) y devuelven directamente las clases
generadas por Drift.

**Por qué:** no existe todavía ningún consumidor (caso de uso, Riverpod,
UI) que necesite una segunda implementación o que necesite desacoplarse de
Drift — agregar la interfaz y el mapeo ahora sería estructura para un
problema que no existe (mismo criterio que se usó para posponer Riverpod).
El paso "5. Modelos" del roadmap se fusiona con este: las clases de Drift
son el modelo, no se duplican a mano.

**Consecuencia documentada (no un olvido):** la validación de la regla de
solapamiento y el cálculo de precio por noche viven hoy dentro de
`ReservationRepository.createGroupReservation`, que en Clean Architecture
"pura" serían responsabilidad de un caso de uso (paso 7 del roadmap). Se
dejaron ahí porque es el único lugar que hoy existe con acceso a la base de
datos, y moverlas a un caso de uso más adelante es una extracción mecánica
que no debería cambiar su comportamiento ni sus tests.

**Ubicación de `AppSettingsRepository`:** vive en `core/settings/`, no en
una feature — igual que la base de datos, es transversal a toda la app.

**Estado:** vigente. Repositories creados en
`features/properties/data/property_repository.dart`,
`features/rooms/data/{room_repository,room_type_repository}.dart`,
`features/guests/data/guest_repository.dart` (se creó la carpeta de la
feature `guests`, que faltaba en el scaffold inicial),
`features/reservations/data/{reservation_repository,payment_repository}.dart`
y `core/settings/app_settings_repository.dart`. Validados con
[reservation_repository_test.dart](../test/features/reservations/data/reservation_repository_test.dart):
cálculo de precio mixto entre-semana/fin-de-semana, rechazo de solapamiento,
y aceptación de rotación el mismo día.

---

## 2026-05-21 — Casos de uso: extracción de reglas puras + solo donde hay algo real que validar

**Contexto:** paso 7 del roadmap. `ReservationRepository` ya tenía adentro
las dos reglas de negocio (solapamiento, precio por noche), dejadas ahí
deliberadamente como pendiente de extracción (ver la entrada de
repositories, más arriba).

**Decisión, parte 1 — extracción:** se sacaron las dos reglas a funciones
puras (sin Drift, sin `Future`, sin base de datos) en
`features/reservations/domain/`:
- `reservation_availability.dart` → `dateRangesOverlap(...)`.
- `reservation_pricing.dart` → `calculateSubtotalCents(...)`.

`ReservationRepository` ahora solo hace dos cosas: trae de la BD las
estadías activas de una habitación (`_getActiveBookings`, una query simple)
y orquesta la transacción de inserción — la interpretación de "qué es
solaparse" y "cuánto cuesta una noche" ya no vive ahí. La transacción
completa (chequeo + inserción) se mantuvo **dentro del repository**, no se
partió entre capas: separar el chequeo de disponibilidad de la inserción a
través de la frontera repository/caso-de-uso habría roto la atomicidad
que da `_db.transaction()` (ventana de carrera entre "verificar" e
"insertar"). La atomicidad es un problema de persistencia, así que se queda
en el repository; las fórmulas puras sí se movieron al dominio.

**Decisión, parte 2 — qué sí se convierte en caso de uso:** solo dos,
ambos en `features/reservations/domain/usecases/`:
- `CreateReservationUseCase`: valida que cada habitación tenga
  `guestsCount > 0` (nadie lo validaba todavía) antes de llamar al
  repository.
- `RegisterPaymentUseCase`: valida que `amountCents != 0` (un pago de
  monto cero no tiene sentido) antes de llamar al repository.

**Por qué no hay un caso de uso por cada método de cada repository:** para
`Property`, `RoomType`, `Room` y `Guest` el CRUD no tiene ninguna regla
adicional que validar hoy — envolver `PropertyRepository.create(...)` en
un `CreatePropertyUseCase` que solo reenvía la llamada sería la misma
ceremonia sin contenido que se evitó con `Owner`, con el enum de tipos de
habitación, etc. Cuando Riverpod (paso 8) exista, esas pantallas van a
llamar al repository directo. Un caso de uso se agrega ahí el día que
aparezca una regla real que otro tipo de dato no puede resolver (ej. "no se
puede desactivar la única propiedad que existe").

**Estado:** vigente. Refactor de `ReservationRepository` no cambió su
comportamiento — los 5 tests que ya existían siguen pasando sin tocar.
Nuevas pruebas puras sin base de datos en
[reservation_pricing_test.dart](../test/features/reservations/domain/reservation_pricing_test.dart)
y
[reservation_availability_test.dart](../test/features/reservations/domain/reservation_availability_test.dart),
más pruebas de los dos casos de uso en
`test/features/reservations/domain/usecases/`.

---

## 2026-05-21 — Tercera tarifa (feriados), a partir de un caso real

**Contexto:** información real de un hostal existente (Hospedaje Shejiná,
Cuenca) mostró una tarifa de feriado ($20/persona) distinta tanto de la
tarifa entre semana ($12) como de la de fin de semana ($15). Esto **revisa**
la pregunta 3 del PRD, que se había cerrado con "2 tarifas: entre semana /
fin de semana" por falta de evidencia de necesitar más.

**Por qué se trata distinto al descuento de niños:** el descuento de niños
es inconsistente ("a veces sí a veces no", decisión de la administradora
caso a caso) — por eso se resolvió con precio editable a mano, sin
automatizarlo. La tarifa de feriado, en cambio, es **fija y predecible**
($20 siempre que sea feriado) — automatizarla es correcto acá; dejarla al
ajuste manual arriesgaría que se olvide en cada feriado real.

**Decisión:**
- Nueva tabla `Holidays` (`date`, `name` opcional, `date` con restricción
  `UNIQUE`), cargada a mano por la administradora — sin integración a un
  calendario de feriados externo (los feriados en Ecuador además se
  trasladan de fecha, lo que haría frágil cualquier calendario
  hardcodeado).
- `Room` gana un tercer campo, `ratePerPersonHolidayCents`, igual de
  explícito que los otros dos (no una fórmula derivada) — porque no hay
  evidencia de que la tarifa de feriado sea siempre "tarifa de fin de
  semana + X" para toda habitación (la habitación individual, por ejemplo,
  tiene toda su estructura de precios distinta a la compartida).
- **Prioridad de tarifas:** feriado > fin de semana > entre semana. Un
  feriado que cae en fin de semana cobra tarifa de feriado, no de fin de
  semana.
- `calculateSubtotalCents` (función pura en
  `features/reservations/domain/reservation_pricing.dart`) recibe ahora
  `ratePerPersonHolidayCents` y un `Set<DateTime> holidayDates` — sigue sin
  tocar la base de datos; es `ReservationRepository` quien lee `Holidays` y
  arma ese set antes de llamarla.
- Nuevo `HolidayRepository` en `core/settings/` (junto a
  `AppSettingsRepository`) — es configuración transversal, no de una
  feature específica.

**Estado:** vigente. Validado con casos de prueba explícitos: feriado en
día de semana, feriado en fin de semana (ambos deben cobrar tarifa de
feriado), y un test end-to-end en
[reservation_repository_test.dart](../test/features/reservations/data/reservation_repository_test.dart)
que carga un feriado real y verifica el precio total de la reserva.

**Nota sobre el proceso:** este cambio no salió de una pregunta que nos
hicimos nosotros, sino de información real de un negocio real compartida a
mitad de camino. El PRD y esta bitácora están para absorber justamente este
tipo de ajuste sin perder el rastro de por qué cambió — no es un error del
PRD v1, es evidencia nueva.

---

## 2026-05-21 — Riverpod: solo el cableado (Provider), sin generador de código todavía

**Contexto:** paso 8 del roadmap. Hasta ahora nada en la app construye
`AppDatabase` ni los repositories — cada test lo hacía a mano. Con
repositories y casos de uso reales ya existiendo (pasos 6 y 7), Riverpod
entra a resolver el problema real de "quién construye qué y con qué
dependencias", no antes.

**Decisión, parte 1 — `Provider` simple, no `riverpod_generator`:**
Riverpod moderno ofrece una variante con anotaciones (`@riverpod`) que
genera código con `build_runner`, similar a Drift. Se optó por **providers
manuales** (`Provider<T>((ref) => ...)`) en vez de eso.

**Por qué:** el proyecto ya tiene un `build_runner` (Drift) cuyo propósito
se explicó paso a paso desde el principio ("qué instala, para qué sirve
cada paquete"). Agregar un segundo generador de código ahora mismo
duplicaría esa complejidad justo cuando Riverpod recién se está
presentando por primera vez — mejor ver el cableado explícito
(`Provider(ref.watch(...))`) antes de delegarlo a un generador. Se puede
migrar a `riverpod_generator` más adelante sin cambiar el comportamiento.

**Decisión, parte 2 — un archivo `*_providers.dart` por feature:**
`core/database/database_providers.dart` (el único que construye la
conexión real, vía `AppDatabase.connect()`), `core/settings/
settings_providers.dart`, y uno por feature:
`features/properties/properties_providers.dart`,
`features/rooms/rooms_providers.dart`,
`features/guests/guests_providers.dart`,
`features/reservations/reservations_providers.dart` (repositories y los
dos casos de uso de esa feature, juntos).

**Por qué:** un provider por repository/caso de uso en archivos separados
sería demasiada fragmentación para lo que hay hoy (una feature con 1-2
repositories); un solo archivo gigante de providers para toda la app
repetiría el error que se evitó desde el principio con
`app_database.dart`. Un archivo por feature es el punto intermedio: fácil
de encontrar, fácil de leer completo.

**Estado:** vigente. `main.dart` envuelve la app en `ProviderScope`.
Validado con
[reservations_providers_test.dart](../test/features/reservations/reservations_providers_test.dart):
resuelve `createReservationUseCaseProvider` y `registerPaymentUseCaseProvider`
a través de toda la cadena de providers (con `appDatabaseProvider`
sobreescrito por una base de datos en memoria, sin tocar el dispositivo) y
los ejecuta de punta a punta. Sin `FutureProvider`/`StreamProvider`/
`Notifier` todavía — eso es el paso 9 (estado reactivo), cuando exista una
pantalla real que necesite mostrar loading/error/data.

---

## 2026-05-21 — Estado reactivo: `Stream` (no `Future`) para el primer caso real, solo en `properties`

**Contexto:** paso 9 del roadmap. Con el cableado de Riverpod ya hecho
(paso 8), tocaba elegir cómo exponer datos a una pantalla: ¿una foto única
(`Future`/`FutureProvider`) o algo que se actualice solo cuando los datos
cambian (`Stream`/`StreamProvider`)?

**Decisión:** `StreamProvider` sobre `Stream<List<Property>>`, usando
`.watch()` de Drift en vez de `.get()`. Solo se hizo para `properties`
(`PropertyRepository.watchActive()` +
`features/properties/properties_providers.dart` →
`activePropertiesProvider`) — no se replicó todavía a `rooms`, `guests` ni
`reservations`.

**Por qué `Stream` y no `Future`:** Drift ya expone reactividad gratis
sobre SQLite (`.watch()` en vez de `.get()` es prácticamente el mismo
código). Con `Future`, la pantalla de propiedades tendría que invalidar el
provider a mano cada vez que se crea/edita/desactiva una propiedad
(fácil de olvidar en algún lugar). Con `Stream`, la UI se actualiza sola
porque Drift emite un valor nuevo cuando cambia la tabla — encaja
naturalmente con la app siendo offline-first y local.

**Por qué solo `properties` y no las demás features todavía:** no existe
hoy ninguna pantalla real (`rooms`, `guests`, `reservations` siguen siendo
placeholders) que necesite consumir esto — replicar el patrón a las 4
features restantes ahora sería trabajo especulativo. `properties` se
adelantó porque es la ruta inicial de la app (`initialRoute` en
`app_routes.dart`) y el candidato obvio para el paso 10. El mismo patrón
(`watchX()` en el repository + `StreamProvider` en el archivo de providers
de la feature) se replica cuando cada pantalla lo necesite de verdad.

**Estado:** vigente. Validado en dos niveles:
[property_repository_test.dart](../test/features/properties/data/property_repository_test.dart)
prueba la reactividad de Drift directamente (crear/desactivar emite listas
nuevas por el stream, sin pasar por Riverpod);
[properties_providers_test.dart](../test/features/properties/properties_providers_test.dart)
prueba que `activePropertiesProvider` expone `AsyncValue` (loading → data) y
se actualiza solo después de una escritura a través del repository, sin
invalidar nada a mano.

---

## 2026-05-21 — UI dinámica: `PropertiesPage` real; sin widget test por una fricción conocida de Drift+Riverpod+flutter_test

**Contexto:** paso 10 del roadmap. `PropertiesPage` (antes un
`Text("Your Properties")` estático) pasó a ser un `ConsumerWidget` que
consume `activePropertiesProvider`: loading/error/lista/estado vacío, más
un diálogo mínimo para crear (nombre) y un ícono para desactivar por fila.

**Verificación real, no solo compilación:** se corrió la app compilada en
el simulador de iOS (`flutter build ios --debug --simulator` +
`AppDatabase.connect()` real, con archivo `.sqlite` de verdad en el
dispositivo, no en memoria) y se probó el camino feliz a mano: crear
"Hospedaje Shejiná" → aparece solo en la lista sin ninguna recarga manual;
tocar el ícono de borrar → desaparece solo. Confirma end-to-end que
`StreamProvider` + `.watch()` de Drift funciona con la conexión real del
dispositivo, no solo con `NativeDatabase.memory()` en tests.

**Por qué no hay un widget test (`testWidgets`) para esta pantalla:**
se intentó, y se topó con una fricción real y reproducible entre Drift,
Riverpod y `flutter_test`: al desmontar un widget que tiene un
`StreamProvider` envolviendo un `.watch()` de Drift, Riverpod dispara
`StreamProviderElement.dispose()` → Drift's `StreamQueryStore.markAsClosed`
agenda un `Timer(Duration.zero)` para cerrar el stream. El binding de test
(`AutomatedTestWidgetsFlutterBinding`, que usa `fake_async` para rastrear
timers) revisa "¿quedó algún timer pendiente?" y falla con `A Timer is
still pending even after the widget tree was disposed` — incluso forzando
el desmontaje dentro del test (reemplazando el árbol por un `SizedBox` y
pumpeando de nuevo antes de terminar), el timer seguía sin alcanzar a
completarse antes de que el binding revisara. En un intento el proceso de
`flutter test` quedó directamente colgado (sin uso de CPU, sin avanzar)
durante ~15 minutos, no solo lento.

**Por qué se decidió no seguir insistiendo:** la funcionalidad ya está
verificada dos veces de forma confiable y rápida (reactividad de Drift en
`property_repository_test.dart`, cableado de Riverpod en
`properties_providers_test.dart`, ambos corriendo en ~1 segundo) más la
prueba manual real en el simulador. Seguir peleando con el timing exacto
de teardown de `flutter_test` para un tercer nivel de test que solo
repetiría la misma cobertura tenía un costo de tiempo abierto y creciente,
sin una solución conocida de antemano — se cortó ahí en vez de seguir
intentando arreglos a ciegas.

**Si se retoma en el futuro:** investigar si versiones más nuevas de
Drift/Riverpod resuelven este caso, o si hay que envolver el `.watch()`
con algo que cierre el stream de forma síncrona antes del dispose. Mientras
tanto, las pantallas nuevas con `StreamProvider` se verifican con el mismo
patrón de dos niveles (repository + provider) usado acá, más prueba manual
en simulador — no con `testWidgets`.

**Estado:** vigente. `lib/features/properties/presentation/pages/properties_page.dart`
es la primera pantalla real conectada a datos reales de la app.

---

## 2026-05-21 — `RoomsPage`: mismo patrón, agrupado por propiedad; gotcha nuevo con `.future` + `join()`

**Contexto:** replicar el patrón de `properties` para `rooms`. A diferencia
de `Property`, una `Room` siempre pertenece a una `Property` — no hay
todavía navegación con argumentos (`AppRoutes` es un mapa estático sin
parámetros), así que construir "tocar una propiedad para ver sus
habitaciones" habría sido más alcance del pedido.

**Decisión:** `RoomsPage` muestra **todas** las habitaciones activas de
**todas** las propiedades en una sola lista, agrupada visualmente por
nombre de propiedad (sin selección de propiedad ni navegación nueva).
`RoomRepository.watchAllActive()` hace un `join()` con `Properties` y
devuelve `(room: Room, propertyName: String)` — el nombre ya resuelto, para
no repetir la consulta en la UI.

**El diálogo de alta es más grande que el de `Property`,** no por exceso:
`Room` tiene más campos obligatorios en el schema (propiedad, tipo de
habitación, capacidad, 3 tarifas). El diálogo deja elegir una propiedad
existente y un `RoomType` existente, con un "+" para crear un tipo nuevo
sin salir del formulario (PRD 5.2: "elegido de los tipos ya creados o uno
nuevo creado al vuelo"). Las 3 tarifas se ingresan en formato decimal
("12", "12.50") y se convierten a centavos en la UI (`* 100`, redondeado) —
la capa de datos sigue en enteros, como se decidió para dinero.

**Gotcha nuevo encontrado al testear (distinto al de los widget tests):**
`container.read(streamProvider.future)` se cuelga (timeout de 30s) cuando
el `StreamProvider` envuelve una consulta con `.join()` sobre varias
tablas — aunque la MISMA consulta, escuchada directo con `.listen()` sin
pasar por Riverpod, emite bien y rápido (confirmado con un test aparte).
Se resolvió evitando `.future` en el test: usar `container.listen(...)` +
esperar un tick (`await Future.delayed(Duration.zero)`) y leer
`container.read(provider).value`, que es exactamente el mecanismo que la
UI real usa (`ref.watch` + `AsyncValue`), no `.future`. La app en sí nunca
usa `.future` en ningún provider, así que este problema es puramente de
cómo se escriben los tests, no afecta el comportamiento real — pero hay
que recordarlo: **no usar `.future` en tests de `StreamProvider` que
envuelven un `.join()`**, usar `container.listen` en su lugar.

**Verificación real:** probado a mano en el simulador con datos del caso
real de Hospedaje Shejiná (Dormitorio compartido, $12/$15/$20): crear tipo
de habitación inline, crear la habitación, aparece agrupada bajo su
propiedad; desactivar la saca de la lista sola.

**Estado:** vigente. Validado con
[room_repository_test.dart](../test/features/rooms/data/room_repository_test.dart)
y
[rooms_providers_test.dart](../test/features/rooms/rooms_providers_test.dart).
Sin `testWidgets`, mismo criterio que `properties`.

---

## 2026-05-21 — `GuestsPage`; corrección: `.future` es poco confiable en general, no solo con `join()`

**Contexto:** replicar el patrón para `guests` (sin relación a `Property`,
más simple que `Room`). En el camino se escribió
`guests_providers_test.dart` usando `container.read(guestsProvider.future)`
para leer el valor inicial — **exactamente el mismo patrón que ya usaba
`properties_providers_test.dart` con éxito**. Este test también se colgó
30s y falló, aunque `guestsProvider` no tiene ningún `join()`.

**Corrección a la entrada anterior** (la de `RoomsPage`, arriba): ahí se
concluyó que el problema era específico de `StreamProvider` + `.join()`.
Esta nueva evidencia lo contradice — el mismo síntoma apareció en una
consulta simple (`select` + `orderBy`, sin join). La entrada anterior no se
edita (esta bitácora es append-only), pero la conclusión correcta es más
amplia: **`container.read(streamProvider.future)` es poco confiable con
cualquier provider respaldado por `.watch()` de Drift**, no solo los que
usan `join()`. La causa raíz exacta (por qué `.future` en particular
dispara esto y `container.listen` no) no se investigó a fondo — alcanza con
saber que hay que evitarlo.

**Regla adoptada para todos los tests de ahora en adelante:** nunca usar
`streamProvider.future`. En su lugar, `container.listen(provider, (_, _)
{})` (dispara la suscripción) + `await Future.delayed(Duration.zero)` +
`container.read(provider).value`. Esto además tiene la ventaja de probar el
mismo mecanismo que usa la UI real (`ref.watch` + `AsyncValue`), en vez de
una API (`.future`) que la app nunca usa. Se corrigieron
`properties_providers_test.dart` (que "funcionaba" pero por una condición
de carrera favorable, no por ser realmente seguro) y
`rooms_providers_test.dart` para seguir esta regla de forma consistente.

**Guests, por lo demás:** mismo patrón que las anteriores.
`GuestRepository.watchAll()`, `guestsProvider`, `GuestsPage` con búsqueda
por nombre/documento filtrada en memoria sobre la lista reactiva ya cargada
(sin query nueva ni provider parametrizado — PRD 5.3). A diferencia de
`Property`/`Room` (que se desactivan), `Guest` se borra de verdad; el
borrado está envuelto en `try/catch` porque `PRAGMA foreign_keys = ON`
puede rechazarlo si el huésped tiene reservas asociadas — es el primer
lugar de la app donde ese error es realmente alcanzable desde la UI.
También se agregaron la ruta `/guests` y su entrada en `AppDrawer`, que
faltaban desde que se creó la feature (paso 6).

**Estado:** vigente. Validado con
[guest_repository_test.dart](../test/features/guests/data/guest_repository_test.dart)
y
[guests_providers_test.dart](../test/features/guests/guests_providers_test.dart).
Probado a mano en simulador: alta, lista, búsqueda sin resultados.

---

## 2026-05-21 — `ReservationsPage`: la pantalla más grande, tres piezas nuevas

**Contexto:** última feature del patrón "replicar UI dinámica". A
diferencia de `properties`/`rooms`/`guests` (una lista + un diálogo de
alta), `Reservation` necesitaba tres pantallas por la complejidad real del
dominio (grupo de habitaciones + pagos + estado):

1. **`ReservationsPage`** — lista reactiva (`ReservationRepository.watchAll()`,
   join con `Guests` para el nombre) con guest, fechas, estado y precio
   total.
2. **`CreateReservationPage`** — página completa (`Navigator.push`, no un
   diálogo): elegir huésped (reactivo, con "+" para crear uno nuevo inline
   reutilizando `AddGuestDialog`), fechas con `showDatePicker`, y una lista
   *dinámica* de asignaciones habitación↔personas (agregar/quitar filas)
   que se manda tal cual a `CreateReservationUseCase` ya existente desde el
   paso 7.
3. **`ReservationDetailPage`** — habitaciones asignadas con subtotal,
   precio total, lista de pagos, saldo pendiente, botón para registrar pago
   y dropdown para cambiar estado.

**Decisión de arquitectura — `FutureProvider.family`, no `StreamProvider`,
para el detalle:** `reservationDetailProvider` (join de `Reservation` +
`Guest` + `ReservationRoom`+`Room` por línea + `Payment`) es una foto única
que se refresca a mano con `ref.invalidate(reservationDetailProvider(id))`
después de cada acción (pago, cambio de estado), en vez de un stream
persistente. Por qué: una pantalla de detalle se abre de nuevo cada vez que
se entra a ella (no necesita quedar "viva" de fondo como la lista), así que
alcanza con invalidar bajo demanda — más simple que armar un stream
compuesto de 4 tablas.

**Bug real encontrado probando el camino feliz en el simulador:** overflow
de 27px en el `DropdownButtonFormField` de habitación dentro de
`CreateReservationPage`, porque el texto "Propiedad — Habitación" no entra
en el espacio que le tocaba compartiendo fila con "Personas" y el botón de
quitar. Causa: `DropdownButtonFormField`/`DropdownButton` tienen
`isExpanded: false` por defecto, así que dentro de un `Expanded` no se
constriñen al ancho disponible y pueden desbordar con texto largo. Se
corrigió agregando `isExpanded: true` a **los 6 dropdowns que existen hoy
en la app** (no solo el que desbordó), como medida preventiva — es un
gotcha real de Flutter, no específico de esta pantalla.

**Verificación real en simulador:** se creó una reserva real
(Ana Perez, Cuarto 1, 22/09/2026 → 24/09/2026, 2 personas) y el precio
calculado ($48.00 = $12 × 2 personas × 2 noches entre semana) coincidió
exactamente con lo esperado. Se registró un pago parcial de $20 y el saldo
se actualizó solo a $28.00 sin recargar nada a mano. Se cambió el estado a
"Confirmada" desde el detalle y se reflejó solo en la lista (reactividad
extremo a extremo, dos pantallas separadas).

**Estado:** vigente. Validado con
[reservation_repository_watch_test.dart](../test/features/reservations/data/reservation_repository_watch_test.dart)
y
[reservations_providers_watch_test.dart](../test/features/reservations/reservations_providers_watch_test.dart)
(crear reserva → aparece en lista → detalle → registrar pago → saldo se
actualiza, todo en un solo test). Con esto, las 6 features del scaffold
original (`properties`, `rooms`, `guests`, `reservations`) tienen UI real
conectada a datos reales — quedan `dashboard`, `calendar` y `reports` como
placeholders, fuera del alcance de esta sesión.

---

## 2026-05-21 — Vehículos (garaje) y notas de reserva, a partir de un caso real

**Contexto:** información real de negocio: el garaje incluido es una de las
mayores fortalezas del hospedaje, y cada auto debe registrarse con su placa
atada al huésped — si un auto está mal estacionado o bloquea a otro, hay que
poder llamar exactamente a ese huésped. Además, todos los días la
administradora arma a mano la lista de placas para enviarla por WhatsApp al
dueño del garaje (un tercero, no el dueño de la propiedad). Un huésped puede
declarar más de un auto, y eso (o una multa) podría implicar un cobro extra.

**Decisión 1 — `Vehicle` como tabla propia, atada a `Reservation` (no a
`Guest` directamente):** un huésped puede declarar más de un vehículo, y el
reporte diario es "qué autos van a estar esta noche", que es exactamente la
estadía activa — no un registro histórico permanente por huésped. Atarlo a
`Reservation` ya ata transitivamente al huésped (vía `Reservation.guestId`)
sin duplicar la relación. Se descartó guardarlo como texto separado por
comas en `Reservation`: el futuro botón de exportar a Excel necesita filas,
no parsing de texto — el costo de una tabla con un solo campo (`plate`) es
mínimo, mismo criterio que se usó para `RoomType` y `Holiday`.

**Decisión 2 — cobro extra por auto adicional/multa: ajuste manual +
notas, no una tarifa automática (confirmado con el usuario):** la frase
"se podría cobrar" indicaba que no es una regla fija, igual que el
descuento de niños. Se reutiliza el mismo mecanismo ya existente
(`overrideTotalPrice`) en vez de construir un sistema de "cargos extra"
estructurado para una regla que ni siquiera es consistente.

**Decisión 3 — `Reservation.notes` (texto libre):** cubre dos necesidades
mencionadas por el usuario con el mismo campo: pedidos especiales (ej.
"desayuno a las 7") y el motivo de un ajuste manual de precio (ej. "auto
extra +$5"). No se separaron en dos campos porque ambas son texto libre sin
estructura real que aprovechar.

**Bug real encontrado en el camino:** al agregar la tabla `Vehicles` y la
columna `Reservations.notes` sin subir `schemaVersion`, la app quedó
colgada al abrir en el simulador — el archivo `.sqlite` del dispositivo ya
existía con el schema viejo, y Drift no crea tablas ni columnas nuevas en
una base existente si `schemaVersion` no cambia (`onCreate` solo corre para
una base nueva, `onUpgrade` solo si la versión sube). Como todavía no hay
usuarios reales ni datos que preservar, se resolvió desinstalando la app
del simulador en vez de escribir una migración — **esto no sería válido
una vez que haya datos reales de producción**: ahí sí hay que subir
`schemaVersion` y escribir un `onUpgrade`. Anotado para no repetir el
mismo susto más adelante.

**Cabo suelto encontrado y corregido en el camino:** `overrideTotalPrice`
existía en `ReservationRepository` desde la decisión del descuento de
niños, pero nunca se conectó a ningún control de UI — nadie podía usarlo
realmente. Se agregó un ícono de edición junto a "Precio total" en
`ReservationDetailPage` (`EditPriceDialog`), con un texto de ayuda que dice
explícitamente que es un ajuste manual sin fórmula fija y que el motivo va
en Notas.

**Estado:** vigente. Probado a mano en simulador de punta a punta: declarar
2 vehículos (placas normalizadas a mayúsculas), editar notas, y ajustar el
precio final de $24 a $29 (el saldo pendiente se recalculó solo). Sección
5.9 del PRD (Excel para el dueño del garaje) queda anotada en "Ideas
futuras" — el modelo ya está listo para esa consulta cuando se construya.

---

## 2026-05-21 — Dashboard (PRD 5.7): un `Provider` derivado, no un stream nuevo

**Contexto:** el Dashboard (PRD 5.7) necesita ocupación actual, check-ins y
check-outs de hoy, e ingresos de hoy/mes. Las cuatro cosas se pueden
calcular a partir de datos que otras pantallas ya cargan de forma
reactiva: reservas (con nombre de huésped), habitaciones activas, líneas
de habitación asignada, y pagos.

**Decisión de arquitectura — combinar providers existentes en vez de una
query nueva:** se agregaron solo las dos piezas reactivas que faltaban
(`PaymentRepository.watchAll()` y
`ReservationRepository.watchAllRoomAssignments()`, cada una con su
`StreamProvider`), y `dashboardDataProvider` es un `Provider<AsyncValue<DashboardData>>`
plano que hace `ref.watch` de los cuatro `StreamProvider`s
(`reservationsProvider`, `activeRoomsProvider`,
`reservationRoomAssignmentsProvider`, `paymentsProvider`), combina a mano
sus estados de loading/error, y calcula el resumen en memoria. Por qué: el
Dashboard es literalmente un resumen de datos que ya existen en la app —
escribir una quinta consulta SQL solo para esto habría sido duplicar
lógica (la regla de "ocupada ahora" ya vive implícitamente en cómo
`Reservation`/`ReservationRoom` se relacionan) sin ninguna ganancia real de
rendimiento a esta escala.

**Regla de "ocupada ahora":** una habitación cuenta como ocupada si tiene
una línea de asignación cuya reserva no está cancelada y cuyo rango
`[checkInDate, checkOutDate)` contiene el instante actual — mismo criterio
de medio-abierto que ya se usa para la rotación el mismo día (PRD 5.10,
`dateRangesOverlap`), aplicado aquí contra "ahora" en vez de contra otro
rango.

**Verificación:** sin `testWidgets` (mismo gotcha de Drift+Riverpod+
`flutter_test` de siempre). Se agregaron tests de repositorio
([reservation_repository_watch_test.dart](../test/features/reservations/data/reservation_repository_watch_test.dart)
para `watchAllRoomAssignments`,
[payment_repository_watch_test.dart](../test/features/reservations/data/payment_repository_watch_test.dart)
para `watchAll`) y un test de contenedor Riverpod
([dashboard_providers_test.dart](../test/features/dashboard/dashboard_providers_test.dart))
que arma 2 habitaciones y 2 reservas (una ocupando/check-in hoy, otra con
check-out hoy) y verifica el resumen completo. Nota técnica nueva:
`dashboardDataProvider` depende de 4 `StreamProvider`s encadenados, así que
tras cada mutación hace falta más de un `Future.delayed(Duration.zero)`
para que todos terminen de emitir — el test usa un `_pump()` de 5 vueltas
en vez de una sola espera, a diferencia de los tests de un solo stream que
alcanzaban con una.

Probado también a mano en el simulador con los datos reales de prueba
(Hospedaje Shejina, Ana Perez, Cuarto 1): mostró "1 / 1 habitaciones
ocupadas", el check-in de hoy tappable navegando al detalle real de la
reserva, e ingresos de $10.00 coincidiendo con el pago registrado.

**Estado:** vigente. Con esto, 5 de las 7 features del scaffold original
tienen UI real conectada a datos reales — quedan `calendar` y `reports`
como placeholders, fuera del alcance de esta sesión.

---

## 2026-05-21 — Calendar (PRD 5.6): mismo patrón de provider derivado, filtrado por propiedad

**Contexto:** el Calendar (PRD 5.6) pide ver, por propiedad, qué
habitación está ocupada en qué fecha, sin importar a qué reserva/grupo
pertenece. Igual que el Dashboard, es un resumen de datos que ya existen
(`activeRoomsProvider`, `reservationRoomAssignmentsProvider`,
`reservationsProvider` para el nombre del huésped) — no hizo falta ninguna
tabla ni columna nueva.

**Decisión de arquitectura — `Provider.family<AsyncValue<...>, String>`
por `propertyId`:** `roomOccupancyProvider` en
`features/calendar/calendar_providers.dart` combina los 3 providers de
arriba, filtra las habitaciones a las de la propiedad pedida, y arma para
cada una la lista de estadías activas (`RoomStay`: rango de fechas +
nombre de huésped + id de reserva, para poder navegar al detalle). Se usó
`.family` (no un provider fijo) porque el resultado depende de qué
propiedad eligió la administradora — mismo motivo que
`reservationDetailProvider` usa `.family` por `reservationId`.

**Decisión de UI — vista semanal con navegación, no un mes completo:** un
grid de 7 días (lunes a domingo) con flechas anterior/siguiente cabe sin
scroll horizontal en una pantalla de celular y ya resuelve la necesidad
real (ver ocupación de los próximos días); un calendario mensual completo
habría sido más complejo de renderizar (grid de hasta 6 semanas, celdas
más chicas) sin que el PRD pidiera esa granularidad. Se puede ampliar a
mes después si hace falta de verdad.

**Verificación:** sin `testWidgets` (mismo gotcha de siempre). Test de
contenedor Riverpod
([calendar_providers_test.dart](../test/features/calendar/calendar_providers_test.dart))
con 2 propiedades y 3 habitaciones, verificando que `roomOccupancyProvider`
filtra por `propertyId`, marca ocupada solo la habitación y el rango de
fechas correctos, y no confunde habitaciones de otra propiedad. Probado
también a mano en el simulador: la grilla mostró correctamente las
habitaciones de "Hospedaje Shejina" con sus celdas ocupadas coincidiendo
con las reservas reales, tocar una celda ocupada navegó al detalle
correcto, cambiar a "Casa Sara" (sin habitaciones) mostró el estado vacío,
y las flechas de semana avanzaron el rango mostrado (14/09-20/09 →
21/09-27/09).

**Estado:** vigente. Con esto, 6 de las 7 features del scaffold original
tienen UI real conectada a datos reales — queda `reports` como único
placeholder, fuera del alcance de esta sesión.

---

## 2026-05-21 — Calendar: vista mensual agregada debajo de la semana (mismo caso de uso, más visual)

**Contexto:** el usuario pidió, después de ver la vista semanal, agregar
debajo un calendario de mes completo (los 28-31 días) con color en los
días que tienen alguna reserva, y que tocar un día muestre qué
habitaciones están ocupadas — sin quitar la vista semanal ya construida
("sin alterar lo que ya tenemos... como otro calendario").

**Decisión — reutilizar `roomOccupancyProvider`, cero piezas nuevas de
datos:** el mismo provider que arma la semana ya trae, por habitación,
*todas* sus estadías activas (no filtradas por rango de fechas — ver el
código de `roomOccupancyProvider`), así que la vista mensual es pura UI:
un segundo widget (`_MonthCalendar`) que lee el mismo
`roomOccupancyProvider(propertyId)` y, para cada día del mes, revisa si
alguna habitación tiene una estadía que lo cubra. No se creó ningún
provider ni consulta nueva — coherente con el principio de "no agregar
piezas porque toca" del proyecto.

**Decisión de UI — un día se pinta si *cualquier* habitación está
ocupada (no una grilla habitación×día como la semana):** un mes completo
con una fila por habitación no entra en una pantalla de celular sin
scroll horizontal. Como el pedido era "más visual, de un vistazo", un
punto de color por día alcanza; el detalle de *qué* habitación se resuelve
al tocar el día (`AlertDialog` con la lista de nombres de habitación, o
"Ninguna habitación ocupada este día" si no hay nada) — mismo patrón de
diálogo simple que `EditPriceDialog`/`AddRoomDialog`.

**Decisión de estado — `_monthCursor` (mes) independiente de `_weekStart`
(semana):** son dos controles de navegación separados porque no tienen por
qué mostrar el mismo período (el usuario puede estar viendo la semana
actual y navegando el mes calendario a otro mes para planear). Mismo
motivo por el que el mes usa nombres de mes en español a mano
(`_monthNames`) en vez de agregar el paquete `intl` solo para esto — no
hay otra necesidad de internacionalización en la app todavía.

**Bug evitado, no bug real:** al mover `_OccupancyGrid` de estar envuelto
en `Expanded` a ser un hijo más de un `Column` dentro de
`SingleChildScrollView` (porque ahora hay dos calendarios que scrollean
juntos), se investigó si sus estados de `Center` (loading/error/vacío)
se romperían al perder el `Expanded` que les daba altura acotada.
Resultado: no hace falta nada especial — `Align`/`Center` de Flutter
detecta una altura no acotada del padre y se encoge al tamaño de su hijo
en vez de fallar (a diferencia de un `ListView`/`GridView` sin
`shrinkWrap`, que sí necesita altura acotada — por eso el `GridView` del
mes usa `shrinkWrap: true` y `NeverScrollableScrollPhysics()`, ya que el
scroll real lo maneja el `SingleChildScrollView` exterior).

**Verificación:** sin test de widget nuevo (mismo gotcha de siempre, y acá
además no hay lógica nueva de datos que testear — `_MonthCalendar` solo
reordena visualmente lo que `calendar_providers_test.dart` ya cubre).
Probado a mano en simulador: el mes de septiembre 2026 mostró los mismos
días ocupados que la semana (14, 15 y 18), tocar el 14 mostró "Cuarto 1" y
"Cuarto 7" en el diálogo, tocar un día libre mostró el mensaje vacío, y
navegar a octubre 2026 alineó bien el primer día (jueves) sin ninguna
habitación pintada (no hay reservas ese mes).

**Estado:** vigente.

---

## 2026-05-21 — Reports (PRD 5.8): último placeholder implementado, mismo patrón de siempre

**Contexto:** PRD 5.8 pide dos reportes por rango de fechas: ocupación e
ingresos. A diferencia del Calendar, el texto del PRD no menciona
"por propiedad" — se implementó como un resumen **global** (todas las
propiedades juntas), consistente con esa lectura y con cómo ya funciona el
Dashboard (que tampoco filtra por propiedad).

**Decisión de arquitectura — mismo patrón de provider derivado, otra vez
sin tabla ni consulta nueva:** `reportDataProvider` en
`features/reports/reports_providers.dart` es un
`Provider.family<AsyncValue<ReportData>, DateRange>` (con
`DateRange = ({DateTime start, DateTime end})`, un record — Dart le da
`==`/`hashCode` estructural gratis, así que sirve como key de `.family` sin
envolverlo en una clase) que combina `activeRoomsProvider`,
`reservationRoomAssignmentsProvider` y `paymentsProvider`. Ya es el
tercer feature (`dashboardDataProvider`, `roomOccupancyProvider`, y ahora
este) que se resuelve así — a esta altura es el patrón establecido para
cualquier pantalla de "resumen" en la app.

**Cómo se define "ocupación" en un rango:** se itera cada día del rango
(inclusive en ambos extremos) y, para cada uno, se cuenta cuántas
habitaciones tienen una asignación activa que lo cubre (mismo criterio de
rango medio-abierto `[checkIn, checkOut)` que ya usan el Dashboard y el
Calendar). `occupiedRoomNights` es la suma de esos conteos diarios;
`totalRoomNights` es `habitaciones activas × días del rango`. Es la misma
regla de "ocupada" reutilizada por tercera vez, nunca reescrita.

**UI — `showDateRangePicker` nativo, sin selector propio:** Flutter ya
trae un selector de rango de fechas completo (con edición manual de texto
incluida); no había ninguna razón para construir uno a mano. Rango por
defecto: el mes en curso (día 1 hasta hoy), mismo período que ya usa el
Dashboard para "ingresos del mes".

**Verificación:** test de contenedor Riverpod
([reports_providers_test.dart](../test/features/reports/reports_providers_test.dart))
con 2 habitaciones y un rango de 4 días: una reserva dentro del rango
(3 noches) y otra completamente fuera (no debe contarse), más dos pagos
insertados con `paidAt` explícito (uno dentro del rango, uno fuera) para
verificar que el filtro de ingresos por fecha funciona — se insertó
directo por Drift en vez de vía `addPayment()` porque ese método usa
`DateTime.now()` y no deja fijar `paidAt` a una fecha de prueba.
Probado también a mano en el simulador: el rango por defecto mostró
2/28 noches-habitación (7.1%) e ingresos de $169.00 acumulados en lo que
va del mes; cambiar el rango a octubre 2026 (sin reservas ni pagos) mostró
correctamente 0/60 (0.0%) y $0.00.

**Estado:** vigente. Con esto, las 7 features del scaffold original tienen
UI real conectada a datos reales — no queda ningún placeholder pendiente
del roadmap original.

---

## 2026-05-22 — Configuración (PRD 5.9): feriados y moneda, la feature que quedó "invisible"

**Contexto:** al hacer un alto para revisar qué faltaba, encontramos que
`AppSettingsRepository` y `HolidayRepository` existían completos desde
hacía sesiones (con tests), pero **no había ninguna pantalla que los
usara**. Consecuencia real: la tarifa de feriado (`ratePerPersonHoliday`),
agregada a partir del caso de Hospedaje Shejiná, era literalmente
inalcanzable para la administradora — no había forma de cargar una fecha
en `Holiday` desde la app. Y la moneda no se mostraba en ningún lado: todos
los montos aparecían como `24.00` a secas.

**Decisión de arquitectura — reactivo, no `FutureProvider` + invalidate:**
a diferencia de `reservationDetailProvider` (una foto que se abre de nuevo
cada vez), la pantalla de Configuración queda abierta mientras la
administradora agrega/quita varios feriados seguidos, igual que
`GuestsPage`/`PropertiesPage`. Se agregó `HolidayRepository.watchAll()`
(ordenado por fecha) y `AppSettingsRepository.watchCurrency()`
(`.watchSingleOrNull()` de Drift sobre la única fila de `AppSettings`), y
sus `StreamProvider`s (`holidaysProvider`, `currencyProvider`) en el
`core/settings/settings_providers.dart` que ya existía — mismo patrón
`watchX()` + `StreamProvider` de siempre.

**Decisión de UI — editar moneda es un diálogo, no un campo persistente en
la página:** un `TextField` inline en una página que se reconstruye por
streams corre el riesgo de perder lo que el usuario está escribiendo a
mitad de tipeo (el valor reactivo pisaría el texto local). Se usó el mismo
mecanismo que `EditPriceDialog`/`EditNotesDialog`: un diálogo que recibe el
valor actual una sola vez y devuelve el nuevo con `Navigator.pop`.

**Decisión — código de moneda en texto libre, sin dropdown curado:** no
existe una lista cerrada de monedas en el PRD, y la app no hace ninguna
conversión ni formato específico por moneda (símbolo, decimales) — armar y
mantener un catálogo de monedas LATAM habría sido una pieza que nadie pidió
("no agregar porque toca"). Un `TextField` que guarda el código tal cual
(mayúsculas) alcanza para lo que la app realmente usa: mostrarlo como
sufijo del monto.

**Refactor justificado — `formatCents(cents, currency)` centralizado en
`shared/utils/format_money.dart`:** antes había 3 copias casi idénticas de
`String _formatCents(int cents) => (cents/100).toStringAsFixed(2)` (en
`dashboard_page.dart`, `reports_page.dart`,
`reservation_detail_page.dart`) más un cuarto lugar sin ni siquiera esa
función (`reservations_page.dart` llamaba `toStringAsFixed(2)` inline). Al
tener que inyectar la moneda real en las cuatro, se consolidó en una sola
función compartida en vez de repetir el cambio 4 veces — no es una
abstracción nueva "por si acaso", es eliminar una duplicación real que ya
existía y que ahora había que tocar de todos modos. `EditPriceDialog` no se
tocó: ahí el número es de un campo editable que hay que poder parsear de
vuelta a centavos, no un valor de solo lectura.

**Verificación:** tests de contenedor Riverpod
([settings_providers_test.dart](../test/core/settings/settings_providers_test.dart))
para `currencyProvider` (default `USD`, se actualiza tras `setCurrency`) y
`holidaysProvider` (se actualiza al agregar/quitar, queda ordenado por
fecha). Probado a mano en simulador de punta a punta: agregar un feriado
("Feriado de prueba") lo reflejó solo en la lista sin recargar nada,
borrarlo lo quitó igual de solo, y los 4 lugares que muestran dinero
(Dashboard, Reportes, Reservas, Detalle de reserva) ya muestran el sufijo
de moneda (`169.00 USD`, `24.00 USD`, etc.) en vez del número a secas. La
edición de moneda vía diálogo se validó por el test de contenedor (cambiar
a `COP` y ver `currencyProvider` reflejarlo) — la edición manual en
simulador quedó parcialmente probada (el menú nativo de selección de texto
de iOS es difícil de automatizar por coordenadas de forma confiable) pero
la lógica de guardado es la misma que ya cubre el test.

**Estado:** vigente. `Configuración` ya no es una feature "fantasma" —
tiene ruta (`/settings`), entrada en el drawer, y es alcanzable y usable
por la administradora real.

---

## 2026-05-22 — Editar propiedad, habitación y huésped: mismo cabo suelto que `overrideTotalPrice`, tres veces

**Contexto:** la revisión de alto también encontró que
`PropertyRepository.update()`, `RoomRepository.update()` y
`GuestRepository.update()` existían desde hacía sesiones — cada uno
recibe la entidad completa y hace `_db.update(...).replace(...)` — pero
ninguno estaba conectado a la UI. El PRD pide explícitamente "crear,
**editar**, listar y desactivar" para `Property` y "CRUD" para `Room` y
`Guest`; sin esto, una vez creada una propiedad/habitación/huésped con un
dato mal escrito, no había forma de corregirlo desde la app.

**Decisión — un mismo diálogo para crear y editar, no uno separado por
caso:** `AddGuestDialog` y `AddRoomDialog` ya existían para crear; se les
agregó un parámetro `initial` (`Guest?`/`Room?`) que, si viene con datos,
precarga los controladores y cambia el título a "Editar...". Quien abre el
diálogo decide con `create()` o `update()` según si vino de "+" o de tocar
un ítem de la lista. Evita mantener dos formularios casi idénticos por
entidad. Para `Property` no existía un diálogo propio — el alta usaba un
`AlertDialog` inline con un solo campo (`name`) armado directo en
`PropertiesPage`, a pesar de que la tabla ya tiene `address`, `ownerName`,
`ownerContact` e `isPrimary` desde la pregunta 1 del PRD. Se creó
`AddPropertyDialog` con los 5 campos y el mismo patrón `initial` —
resuelve de una vez tanto "editar" como el hueco de que crear una
propiedad nunca dejó cargar dirección/dueño.

**Cómo arma cada pantalla la actualización:** el diálogo devuelve solo los
valores nuevos (un record, ej. `NewGuestData`); quien llama usa
`entidad.copyWith(...)` sobre la fila ya cargada en la lista (no hace
falta releerla de la base) y pasa el resultado a `update()`. Drift genera
`copyWith` con `Value<T?>` para columnas nullable (`address`, `documentId`,
etc.), así que setear a `null` explícito y "no tocar el campo" son cosas
distintas y ambas están disponibles.

**Cabo suelto menor encontrado de paso:** `GuestRepository` no tenía
`getById` (sí lo tenían `RoomRepository` y `ReservationRepository`) — se
agregó porque el test de `update` lo necesitaba para releer la fila tras
guardar, y es una operación básica que ya faltaba.

**Verificación:** un test de `update()` por repositorio
([property_repository_test.dart](../test/features/properties/data/property_repository_test.dart),
[room_repository_test.dart](../test/features/rooms/data/room_repository_test.dart),
[guest_repository_test.dart](../test/features/guests/data/guest_repository_test.dart)),
cada uno comprobando que el `StreamProvider`/`watchX()` correspondiente
refleja el cambio solo, sin invalidar nada a mano. Probado a mano en
simulador: renombrar "Casa Sara" + cargar dirección + marcarla como
principal se reflejó solo en la lista; renombrar "Cuarto 7" a
"Cuarto 7 B" igual; cargarle un teléfono a "Ana Perez" persistió al
reabrir el diálogo. La edición de tarifa de habitación y de moneda (sesión
anterior) quedaron cubiertas solo por el test automatizado — el menú
nativo de selección de texto de iOS resultó difícil de automatizar de
forma confiable por coordenadas en el simulador, así que no se insistió
más de lo razonable ahí.

**Estado:** vigente. Sigue pendiente (anotado, no resuelto): historial de
reservas por huésped (PRD 5.3) — tocar un huésped hoy abre "editar", no
muestra sus reservas pasadas.

---

## 2026-05-22 — Historial de reservas por huésped: último cabo suelto de la revisión de alto

**Contexto:** cierra el último punto pendiente de PRD 5.3. `Guest` es la
única de las tres entidades (junto con `Property`/`Room`) que tiene algo
más que atributos editables: un historial real de actividad (sus
reservas). Eso cambió la decisión de UX respecto a como quedaron
`Property`/`Room` en la sesión anterior.

**Decisión de UX — `Guest` gana una pantalla de detalle; `Property`/`Room`
no:** tocar una propiedad o habitación en su lista abre directo "editar"
(no tienen "detalle" propio más allá de sus campos). Tocar un huésped
ahora abre `GuestDetailPage` (nombre, contacto, notas, y el historial de
reservas), con la edición movida a un ícono de lápiz junto al nombre —
mismo patrón que "Precio total"/"Notas" en `ReservationDetailPage`. La
diferencia se justifica por la entidad, no por capricho: un huésped
acumula historial con el tiempo, una habitación no.

**Decisión de arquitectura — reactivo también acá, buscando en la lista ya
cargada en vez de un `FutureProvider` propio:** `GuestDetailPage` no pide
el huésped por separado; lee `guestsProvider` (la lista completa, ya
reactiva) y busca el que coincide con el `guestId` recibido por
constructor. Ventaja real: si se edita el huésped desde el mismo ícono de
la pantalla, el nombre de arriba se actualiza solo, sin `ref.invalidate`
— lo mismo que ya pasa en las listas de `properties`/`rooms`/`guests`. El
historial de reservas sí es un provider nuevo
(`reservationsForGuestProvider`, `StreamProvider.family` sobre
`ReservationRepository.watchByGuest()`) porque no existía ningún lugar que
ya cargara "las reservas de un huésped puntual".

**Refactor de paso — tercera duplicación de `_statusLabel` evitada:** ya
existía copiado en `ReservationsPage` y `ReservationDetailPage`; al
necesitarlo una tercera vez en `GuestDetailPage` se consolidó en
`shared/utils/reservation_status_label.dart` (mismo criterio que
`formatCents` en la sesión de Configuración — no se toca por gusto, se
consolida cuando ya hay que tocar el código en varios lados por una razón
real). `_formatDate` (fechas `dd/mm/yyyy`) quedó **sin consolidar** a
propósito: ya estaba duplicado en 5+ lugares antes de esta sesión y
ninguno de ellos se tocó por esta tarea — unificarlos habría sido un
refactor aparte, no consecuencia directa de agregar el historial.

**Verificación:** test de repositorio
([reservation_repository_watch_test.dart](../test/features/reservations/data/reservation_repository_watch_test.dart))
verificando que `watchByGuest` filtra por huésped (no trae las de otro) y
ordena por fecha descendente; test de contenedor Riverpod
([reservations_providers_watch_test.dart](../test/features/reservations/reservations_providers_watch_test.dart))
para `reservationsForGuestProvider`. Probado a mano en simulador: tocar a
"Ana Perez" mostró su teléfono (cargado en la sesión anterior) y sus 2
reservas reales ordenadas por fecha; tocar una navegó al detalle correcto;
el ícono de editar abrió el formulario con todos los campos precargados.

**Estado:** vigente. Con esto, las 7 features del scaffold original más
`Configuración` tienen UI real y completa — no queda ningún punto
pendiente del PRD anotado en esta revisión de alto.
