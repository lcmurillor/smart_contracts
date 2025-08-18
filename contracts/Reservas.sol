// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Realizamos el import para acceder a los turistas
import "./Usuarios.sol";

//Realizamos el import para acceder a los lugares
import "./Lugares.sol";

contract Reservas {
    Usuarios private usuariosContrato;
    Lugares private lugaresContrato;

    mapping(uint256 => Reserva) private reservas;
    uint256 private contadorReservas;

    struct Reserva {
        string nombreLugar;
        uint256 totalCobrado;
        uint8 cuposDisponibles;
        address guiaTuristas;
        uint256 fecha;
        bool estado;
    }

    event reservaRegistrada(uint256 id, string nombreLugar);
    event eliminarRegistrada(uint256 id, string nombreLugar);
    event pagarRegistrada(uint256 id, string nombreTursita, uint256 monto);

    constructor(address _usuariosContrato, address _lugaresContrato) {
        usuariosContrato = Usuarios(_usuariosContrato);
        lugaresContrato = Lugares(_lugaresContrato);
    }

    //Valida que solo el dueño haga cambios.
    modifier soloDuenno() {
        require(
            msg.sender == obtenerDuenno(),
            "Solo el Duenno puede realizar esta accion"
        );
        _;
    }

    //Valida que solo los gúias de turistas puedan hacer cambios.
    modifier soloGuias() {
        require(
            msg.sender == obtenerDuenno() || obtenerGuia(msg.sender).estado,
            "Solo el Duenno o Guias de turistas puede realizar esta accion"
        );
        _;
    }

    //Hace un llamado al contrato de usuarios y se trae al dueño ya que es uno solo
    //para todo el sistema.
    function obtenerDuenno() public view returns (address) {
        return usuariosContrato.verDuenno();
    }

    function obtenerGuia(address _cuenta)
        public
        view
        returns (Usuarios.GuiaTuristas memory)
    {
        return usuariosContrato.verGuia(_cuenta);
    }

    function obtenerTurista(address _cuenta)
        public
        view
        returns (Usuarios.Turista memory)
    {
        return usuariosContrato.verTurista(_cuenta);
    }

    function obtenerLugar(string memory _nombreLugar)
        public
        view
        returns (Lugares.Lugar memory)
    {
        return lugaresContrato.verLugar(_nombreLugar);
    }

    function registrarReservas(
        string memory _nombreLugar,
        address _guiaTuristas
    ) public soloGuias {
        require(
            bytes(_nombreLugar).length > 0,
            "Debe definir el lugar donde sera el Tour"
        );
        require(
            obtenerLugar(_nombreLugar).estado,
            "Deber ser un lugar registrado"
        );
        require(
            obtenerGuia(_guiaTuristas).estado,
            "Deber ser un guia registrado"
        );
        reservas[contadorReservas] = Reserva(
            _nombreLugar,
            0,
            obtenerLugar(_nombreLugar).cupos,
            obtenerLugar(_nombreLugar).guiaTuristas,
            block.timestamp,
            true
        );
        contadorReservas++;
        emit reservaRegistrada(contadorReservas, _nombreLugar);
    }

    function asignarTuristas(uint256 _idReserva) public payable {
        Reserva memory _reserva = reservas[_idReserva];
        Usuarios.Turista memory _turista = obtenerTurista(msg.sender);
        Lugares.Lugar memory _lugar = obtenerLugar(_reserva.nombreLugar);
        require(_reserva.estado, "Esta reserva no se encuentra activa");
        require(
            _reserva.cuposDisponibles > 0,
            "Esta reserva no se encuentra activa"
        );
        require(_turista.estado, "Este turista no se encuentra activo");
        require(_lugar.estado, "Este lugar no se encuentra activo");
        require(msg.value == _lugar.precio, "El monto es incorrecto");

        reservas[_idReserva].totalCobrado += msg.value;
        reservas[_idReserva].cuposDisponibles--;

        payable(obtenerDuenno()).transfer(msg.value);

        emit pagarRegistrada(_idReserva, _turista.nombreCompleto, msg.value);
    }

    function verReservas() public view returns (Reserva[] memory) {
        Reserva[] memory _reservas = new Reserva[](contadorReservas);
        for (uint256 i = 0; i < contadorReservas; i++) {
            _reservas[i] = reservas[i];
        }
        return _reservas;
    }

    function verReserva(uint256 _idReserva)
        public
        view
        returns (Reserva memory)
    {
        return reservas[_idReserva];
    }

    function eliminarReserva(uint256 _idReserva) public {
        require(reservas[_idReserva].estado, "Esta reseva no existe");
        reservas[_idReserva].estado = false;
        emit eliminarRegistrada(_idReserva, reservas[_idReserva].nombreLugar);
    }
}
