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
sin errores (`dart run build_runner build`). Falta la conexión real
(executor con `path_provider`/`path`) — hoy `AppDatabase` solo puede
instanciarse con un executor en memoria/test.
