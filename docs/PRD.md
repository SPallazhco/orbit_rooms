# PRD — OrbitRooms

> Product Requirements Document. Define **qué** debe hacer la app y **para
> quién**, antes de decidir **cómo** se implementa (eso vive en
> [DECISIONS.md](DECISIONS.md) y [CLAUDE.md](../CLAUDE.md)). Se actualiza
> cada vez que cambia el alcance o aparece una regla de negocio nueva.
>
> Estado: **v1 cerrada** — las 7 preguntas iniciales de la sección
> [Preguntas abiertas](#8-preguntas-abiertas--cabos-sueltos) están
> resueltas. Sigue siendo un documento vivo: cualquier regla de negocio
> nueva que aparezca se agrega aquí y se justifica en
> [DECISIONS.md](DECISIONS.md).

## 1. Visión

OrbitRooms es una app Flutter, offline-first y gratuita, para que dueños de
hostales pequeños en LATAM administren reservas, habitaciones y huéspedes sin
depender de internet ni pagar suscripciones.

## 2. Usuario objetivo

**Persona principal:** administradora/administrador de un hostal pequeño o
familiar. Puede:

- Tener **su propio hostal** (propiedad principal), y
- Administrar además **otras propiedades que no le pertenecen** (dueños
  externos le piden que gestione su casa/hostal también).

Es decir: una persona puede administrar **una o varias propiedades** desde el
mismo dispositivo. No hay, por ahora, más de una persona usando la misma
instalación de la app al mismo tiempo (ver sección 6, Usuarios).

## 3. Alcance del MVP

### Dentro de alcance

- Gestión de **múltiples propiedades** (hostales/casas) por instalación.
- Gestión de **habitaciones** por propiedad (tipo, capacidad, precio, estado).
- Gestión de **huéspedes** como entidad con historial propio.
- Gestión de **reservas**: crear, confirmar, check-in, check-out, cancelar.
- Registro de **pago básico** por reserva (monto, método, estado).
- **Vehículos por reserva** (placa): el garaje es una fortaleza real del
  negocio (PRD 5.4) — cada auto debe quedar atado a la reserva/huésped.
- **Notas por reserva**: pedidos especiales y motivo de ajustes manuales de
  precio.
- **Calendario** de disponibilidad/ocupación por propiedad.
- **Dashboard** con resumen operativo (ocupación actual, próximos
  check-in/check-out).
- **Reportes** básicos de ocupación e ingresos por período.
- Funcionamiento **100% offline** (sin internet, sin cuenta, sin backend).

### Fuera de alcance (explícitamente pospuesto, no olvidado)

- Sincronización en la nube / multi-dispositivo.
- Autenticación y roles de usuario (dueño vs recepcionista vs empleado).
- Panel web administrativo.
- Facturación electrónica, integraciones de pasarela de pago.
- Notificaciones/recordatorios automáticos.
- Reportes avanzados / analítica.

Estos puntos están fuera del MVP pero **influyen decisiones técnicas de
hoy** (ver [DECISIONS.md](DECISIONS.md) — UUID como PK pensando en sync
futura, y modelo de `Property` ya preparado para más de una).

## 4. Glosario de dominio (entidades principales)

| Entidad | Descripción |
|---|---|
| **Property** (Propiedad) | Un hostal o casa administrado desde la app. Puede ser la propiedad principal del usuario o una de un tercero que él administra. Contiene habitaciones. |
| **RoomType** (Tipo de habitación) | Etiqueta reutilizable definida por el propio usuario (ej. "Doble", "Dormitorio compartido", "Cabaña"). No es una lista fija impuesta por la app. |
| **Room** (Habitación) | Una unidad reservable dentro de una `Property`. Tiene un `RoomType`, capacidad **orientativa** (no bloqueante), tarifa **por persona** (entre semana / fin de semana / feriado) y estado (activa/inactiva). |
| **Holiday** (Feriado) | Una fecha cargada a mano por la administradora. Mientras esté cargada, cualquier `Room` de cualquier `Property` cobra su tarifa de feriado esa noche, con prioridad sobre entre-semana/fin-de-semana. |
| **Guest** (Huésped) | Persona que se hospeda (o que reserva a nombre del grupo). Entidad propia con historial: puede tener múltiples reservas a lo largo del tiempo, en la misma o distintas propiedades. |
| **Reservation** (Reserva) | Es un **grupo de estadía**: un huésped principal, fechas de check-in/check-out, estado, precio total (editable) y sus pagos. Puede cubrir una o varias habitaciones (ver `ReservationRoom`). Es el corazón operativo de la app. |
| **ReservationRoom** (Habitación asignada) | Línea dentro de una `Reservation`: qué `Room` se asignó y cuántas personas de ese grupo se alojan ahí. Una reserva de 1 sola habitación tiene exactamente una línea. |
| **Payment** (Pago) | Registro de pago asociado a una `Reservation` completa (el grupo), no a una habitación individual: monto, método, estado. Una reserva puede tener uno o más pagos (pago parcial). |
| **Vehicle** (Vehículo) | Placa de un auto declarado para una `Reservation` (el garaje incluido es una fortaleza real del negocio). Un huésped puede declarar más de un vehículo. Atado a la reserva, y por lo tanto al huésped vía `Reservation.guestId`. |

Relaciones:

```
Property (1) ──── (N) Room
RoomType (1) ──── (N) Room
Reservation (1) ── (N) ReservationRoom ── (N:1) Room
Reservation (1) ── (N) Vehicle
Guest    (1) ──── (N) Reservation
Reservation (1) ── (N) Payment
```

## 5. Requerimientos funcionales por módulo

Los módulos coinciden con las features ya creadas en `lib/features/`.

### 5.1 Properties

- Crear, editar, listar y desactivar propiedades.
- Cada propiedad tiene: nombre, dirección, y opcionalmente `ownerName` /
  `ownerContact` como texto libre (nombre y contacto del dueño real, cuando
  la propiedad la administra un tercero — ver [DECISIONS.md](DECISIONS.md)).
  No es una entidad separada: no hay hoy ninguna funcionalidad que dependa de
  eso.
- Permitir marcar una propiedad como la "principal" del usuario (informativo,
  no cambia permisos porque no hay roles todavía).

### 5.2 Rooms

- CRUD de habitaciones, siempre asociadas a una propiedad.
- Campos: número/nombre, `RoomType` (elegido de los tipos ya creados por el
  usuario o uno nuevo creado al vuelo — no es una lista fija de la app),
  capacidad, estado (activa/inactiva).
- **La capacidad es orientativa, no un límite duro:** la app no debe
  bloquear que se asignen más personas de las que indica la capacidad
  nominal — la administradora decide si "se acomodan" o no (ver
  [DECISIONS.md](DECISIONS.md)).
- Los `RoomType` los define y reutiliza el propio usuario (ver
  [DECISIONS.md](DECISIONS.md)); no vienen precargados por la app.
- **Precio: por persona, no por habitación**, con tres tarifas:
  `ratePerPersonWeekday` (lunes a jueves), `ratePerPersonWeekend` (viernes,
  sábado y domingo) y `ratePerPersonHoliday` (cualquier fecha cargada en
  `Holiday`, con prioridad sobre las otras dos — un feriado en fin de semana
  cobra tarifa de feriado, no de fin de semana). No hay tarifas por
  temporada ni por día individual más allá de estas tres categorías (ver
  [DECISIONS.md](DECISIONS.md); revisado a partir de un caso real — antes
  eran solo dos tarifas).

### 5.3 Guests

- CRUD de huéspedes: nombre, documento de identidad, teléfono, email
  (opcional), notas.
- Ver historial de reservas de un huésped (búsqueda por nombre/documento).

### 5.4 Reservations

Una `Reservation` es un **grupo de estadía**, no una habitación individual.
Puede cubrir una o varias habitaciones a la vez (ej. un grupo de 20 personas
repartido en 2-3 habitaciones según capacidad disponible).

- Crear reserva: elegir propiedad → huésped principal (nuevo o existente) →
  fechas de check-in/check-out → asignar una o más habitaciones, indicando
  cuántas personas del grupo va en cada una (`ReservationRoom`).
- Estados: pendiente, confirmada, check-in realizado, check-out realizado,
  cancelada. El estado aplica a la reserva completa (todas sus habitaciones
  se mueven juntas de estado).
- **Regla de negocio no negociable:** una misma habitación no puede estar en
  dos `ReservationRoom` distintos con fechas activas solapadas.
- **La capacidad de la habitación no bloquea la asignación:** se puede
  asignar más personas de las que indica la capacidad nominal de la
  habitación — es una decisión de la administradora, no una validación del
  sistema (ver [DECISIONS.md](DECISIONS.md)).
- check-out debe ser posterior a check-in.
- **Cálculo de precio:** por cada `ReservationRoom`, se calcula un subtotal
  = para cada noche, la tarifa por persona correspondiente (feriado si la
  fecha está en `Holiday`; si no, fin de semana o entre semana según el día)
  × personas asignadas a esa habitación. La suma de subtotales de todas las
  habitaciones da el precio sugerido de la reserva completa. Este precio
  sugerido es un punto de partida, pero **el precio final de la reserva es
  editable a mano** (para descuentos de niños, auto extra, multa u otros
  ajustes que la administradora decide caso a caso — no hay fórmula
  automática, ver [DECISIONS.md](DECISIONS.md)). El motivo del ajuste se
  deja anotado en `notes`, no en un campo estructurado.
- Ver y actualizar el estado de pago de la reserva completa.
- **Vehículos (garaje):** una reserva puede tener cero o más `Vehicle`
  (placa). El garaje incluido es una de las fortalezas reales del negocio;
  cada placa debe quedar atada a la reserva (y por lo tanto al huésped) para
  poder ubicar al dueño de un auto mal estacionado o que bloquea a otro. Un
  huésped puede declarar más de un vehículo. Se agregan/quitan desde el
  detalle de la reserva, no al crearla (no todos los huéspedes llegan en
  auto).
- **Notas:** texto libre por reserva. Cubre pedidos especiales (ej.
  "desayuno a las 7") y el motivo de un ajuste manual de precio.

### 5.5 Payments

- Registrar uno o más pagos contra una **reserva completa** (el grupo paga
  como uno), no contra cada habitación individual.
- Calcular saldo pendiente = precio total de la reserva − suma de pagos.
- Estado derivado: pagado (saldo = 0), parcial (0 < saldo < total), pendiente
  (sin pagos).
- **Reembolsos:** no existe una entidad separada de reembolso. Si hay que
  devolver dinero (ej. por una cancelación), se registra como un `Payment`
  más con **monto negativo** sobre la misma reserva. Cancelar una reserva no
  borra ni recalcula los pagos existentes — quedan como historial (ver
  [DECISIONS.md](DECISIONS.md)).

### 5.6 Calendar ✅ implementado

- Vista de calendario por propiedad mostrando ocupación de cada habitación
  por rango de fechas (una habitación aparece ocupada si tiene un
  `ReservationRoom` activo en esa fecha, sin importar a qué reserva/grupo
  pertenece).
- El rango de fechas es una semana con navegación anterior/siguiente
  (semana calendario, lunes a domingo). Igual que el Dashboard, no es una
  consulta nueva: se arma combinando los providers reactivos que ya
  existen para habitaciones, reservas y asignaciones (ver
  [DECISIONS.md](DECISIONS.md)). Una celda ocupada es tappable y navega al
  detalle de esa reserva.
- Debajo de la semana, una **vista mensual** (todos los días del mes, con
  navegación mes anterior/siguiente) para una lectura más visual de
  ocupación: un día se pinta si *alguna* habitación de la propiedad tiene
  una reserva activa ese día, y tocarlo muestra en un diálogo cuáles
  habitaciones están ocupadas esa fecha. Ambas vistas conviven en la misma
  pantalla (la semana no se quitó al agregar el mes).

### 5.7 Dashboard ✅ implementado

- Resumen: ocupación actual, check-ins y check-outs del día, ingresos del
  período (día/mes).
- No es una consulta nueva: se arma combinando los providers reactivos que
  ya existen para reservas, habitaciones, pagos y asignaciones de
  habitación (ver [DECISIONS.md](DECISIONS.md)). El check-in/check-out del
  día es tappable y navega al detalle de esa reserva, igual que en la
  pantalla de Reservas.

### 5.8 Reports ✅ implementado

- Reporte de ocupación por rango de fechas: noches-habitación ocupadas vs.
  disponibles (todas las habitaciones activas de todas las propiedades × la
  cantidad de días del rango) y el porcentaje resultante.
- Reporte de ingresos (pagos registrados) por rango de fechas: suma de
  `Payment.amountCents` con `paidAt` dentro del rango.
- Es global (todas las propiedades juntas), no filtrado por propiedad — a
  diferencia del Calendar (5.6), acá el PRD no pedía ese filtro y un
  resumen de negocio completo es lo que tiene sentido para "reportes".
  Selector de rango de fechas con el `showDateRangePicker` nativo de
  Flutter; por defecto, el mes en curso (día 1 hasta hoy). Ver
  [DECISIONS.md](DECISIONS.md).

### 5.9 Configuración general

- Un único valor de **moneda**, fijo para toda la instalación (aplica a
  tarifas de `Room`, precios de `Reservation` y montos de `Payment`). No hay
  conversión de moneda ni moneda por propiedad (ver
  [DECISIONS.md](DECISIONS.md)).
- **Feriados (`Holiday`):** lista de fechas cargadas a mano por la
  administradora (fecha + nombre opcional, ej. "Independencia de Cuenca").
  Sin integración a un calendario de feriados externo — se agregan y quitan
  manualmente. Afectan el precio de cualquier habitación de cualquier
  propiedad ese día (ver sección 5.2/5.4 y [DECISIONS.md](DECISIONS.md)).

### 5.10 Horarios de check-in / check-out

- Check-in: **14:00**. Check-out: **11:00**. Son horarios fijos globales
  (no configurables por propiedad por ahora).
- Las fechas de una reserva (`checkInDate`/`checkOutDate` en `Reservation`)
  se manejan como **fechas de calendario, sin hora** — la hora fija de
  14:00/11:00 es una regla de negocio conocida, no un dato que se guarda por
  reserva.
- **Rotación el mismo día:** sí se permite que una habitación tenga
  check-out de una reserva y check-in de otra reserva el mismo día
  calendario (hay margen de limpieza entre 11:00 y 14:00). Por lo tanto, la
  regla de "no solapar fechas" (secciones 5.2/5.4) compara el rango como
  **medio-abierto**: `[checkInDate, checkOutDate)` — el día de checkout de
  una reserva no cuenta como ocupado para esa reserva, así que puede
  coincidir con el checkin de la siguiente.

## 6. Usuarios y autenticación

- MVP: **un solo usuario, sin login**, dueño de todos los datos locales del
  dispositivo.
- El modelo de datos **no debe asumir que nunca habrá más de un usuario**:
  se deja espacio para roles/empleados a futuro, pero no se construye ahora
  (ver [DECISIONS.md](DECISIONS.md)).

## 7. Requerimientos no funcionales

- **Offline-first:** toda funcionalidad del MVP debe operar sin conexión a
  internet.
- **Plataformas:** Android e iOS (ya hay proyectos nativos generados para
  ambos).
- **Idioma:** español (LATAM) como idioma principal de la interfaz.
- **Preparado para sync futura sin implementarla:** IDs únicos globales
  (UUID) en las tablas, para no migrar esquema cuando se agregue
  sincronización.
- **Escalable y entendible:** Clean Architecture + Feature-First ya en uso;
  una tabla Drift por archivo.

## 8. Preguntas abiertas / Cabos sueltos

Se resuelven una a la vez y en orden. Cada una, al resolverse, se mueve a
"Resueltas" con la decisión tomada y se refleja en la sección funcional
correspondiente más arriba y en [DECISIONS.md](DECISIONS.md).

### Resueltas

1. ~~**Dueño real de una propiedad de terceros**~~ — ✅ Resuelto: campo de
   texto libre (`ownerName` / `ownerContact`) en `Property`, no entidad
   separada. Ver sección 5.1 y [DECISIONS.md](DECISIONS.md).
2. ~~**Tipos de habitación**~~ — ✅ Resuelto: entidad `RoomType` mínima
   (solo `nombre`), definida y reutilizada por el propio usuario, no una
   lista fija de la app. Ver sección 5.2 y [DECISIONS.md](DECISIONS.md).
3. ~~**Precio de la habitación**~~ — ✅ Resuelto: precio **por persona**, dos
   tarifas por habitación (entre semana / fin de semana, donde fin de semana
   = viernes+sábado+domingo). Precio de la reserva calculado
   automáticamente pero editable a mano (sin fórmula fija de descuento por
   niños). Ver sección 5.2, 5.4 y [DECISIONS.md](DECISIONS.md).
4. ~~**Moneda**~~ — ✅ Resuelto: una sola moneda fija para toda la app,
   configurada una vez, sin conversión ni moneda por propiedad. Ver sección
   5.9 y [DECISIONS.md](DECISIONS.md).
5. ~~**Reservas multi-habitación**~~ — ✅ Resuelto: `Reservation` es un
   grupo de estadía que puede cubrir una o varias habitaciones vía
   `ReservationRoom`; la capacidad de la habitación es orientativa, no un
   límite duro; el pago se registra sobre la reserva completa, no por
   habitación. Ver sección 4, 5.2, 5.4, 5.5 y [DECISIONS.md](DECISIONS.md).

6. ~~**Cancelación con pago ya registrado**~~ — ✅ Resuelto: no se borra
   nada al cancelar; los pagos quedan como historial. Un reembolso se
   registra como un `Payment` más con monto negativo, sin entidad `Refund`
   separada. Ver sección 5.5 y [DECISIONS.md](DECISIONS.md).

7. ~~**Reglas de check-in/check-out**~~ — ✅ Resuelto: check-in 14:00,
   check-out 11:00 (fijos, globales). Reservas se guardan como fecha sin
   hora. Se permite rotación el mismo día (rango medio-abierto). Ver sección
   5.10 y [DECISIONS.md](DECISIONS.md).

### Pendientes

Ninguna de las 7 preguntas originales. Sí hubo una **revisión post-v1**
(2026-05-21): datos reales de un hostal real (ver
[DECISIONS.md](DECISIONS.md)) mostraron una tercera tarifa (feriados) que
no estaba contemplada en la pregunta 3 — se agregó `Holiday` y
`ratePerPersonHoliday`. El PRD es un documento vivo: esto es exactamente el
tipo de ajuste que se espera que seguir apareciendo con más información
real.

## 9. Ideas futuras (fuera de alcance, no perder de vista)

Cosas mencionadas que no se diseñan ni se construyen todavía, pero vale la
pena no olvidar:

- **Video de presentación por habitación:** cada habitación podría tener un
  video (ej. subido a YouTube) enlazado, para mostrarlo a clientes
  potenciales.
- **Respuestas automáticas / plantillas de WhatsApp:** hoy la administradora
  responde consultas a mano reenviando mensajes e info que ya tiene
  guardados. Un sistema que arme y envíe esa información (disponibilidad,
  videos) por WhatsApp sería una integración externa — fuera del alcance
  offline-first del MVP (ver sección 3).
- **Exportar placas del día a Excel para el dueño del garaje:** hoy la
  administradora arma a mano, todos los días, la lista de placas que van a
  estar en el garaje esa noche y se la envía por WhatsApp al dueño del
  parqueadero (que es un tercero, no el dueño de la propiedad). Un botón que
  genere ese Excel a partir de los `Vehicle` de las reservas activas ese día
  ahorraría el trabajo manual. No se construye ahora porque compartir por
  WhatsApp es una integración externa — pero el modelo de datos (`Vehicle`
  atado a `Reservation`) ya está preparado para esto: es una consulta, no un
  cambio de esquema.

Estas ideas vienen de casos reales (hostales existentes, "Hospedaje
Shejiná"), no son hipótesis — por eso se anotan acá en vez de descartarlas,
aunque no se construyan ahora.
