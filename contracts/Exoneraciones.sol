// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Realizamos el import para acceder a los turistas
import "./Usuarios.sol";

//Realizamos el import para acceder a las reservas
import "./Reservas.sol";

contract Exoneraciones {
    Usuarios private usuariosContrato;
    Reservas private reservasContrato;

    string private mensajeExoneracion;
    uint256 private contadorExoneracion;

    mapping(uint256 => Exoneracion) private exoneraciones;

    struct Exoneracion {
        uint256 id;
        uint256 idReseva;
        address[] turistasExonerados;
    }

    event ExoneracionRegistrada(uint256 id, uint256 idReseva);

    constructor(address _usuariosContrato, address _reservasContrato) {
        usuariosContrato = Usuarios(_usuariosContrato);
        reservasContrato = Reservas(_reservasContrato);
        mensajeExoneracion = "El participante reconoce y acepta que las actividades turisticas ofrecidas por La empresa de gestion de turismo pueden implicar riesgos inherentes, incluyendo pero no limitandose a lesiones fisicas, danos materiales, perdidas economicas o incluso la muerte. Al aceptar este contrato, el participante libera expresamente a La empresa de gestion de turismo, sus representantes, empleados y afiliados de toda responsabilidad civil, penal o administrativa derivada de cualquier incidente ocurrido durante la participacion en dichas actividades, salvo en casos de negligencia grave o dolo comprobado. El participante declara haber sido informado de los riesgos, haberlos comprendido plenamente y asumirlos voluntariamente bajo su propia responsabilidad.";
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

    function obtenerReservas(uint256 _idReserva)
        public
        view
        returns (Reservas.Reserva memory)
    {
        return reservasContrato.verReserva(_idReserva);
    }

    function registrarExoneracion(
        uint256 _idReserva,
        address[] memory _turistas
    ) public soloGuias {
        require(
            obtenerReservas(_idReserva).estado,
            "Debe ingresar un reserva valida"
        );
        require(_turistas.length > 0, "Debe ingresar al menos un turista");
        exoneraciones[contadorExoneracion] = Exoneracion(contadorExoneracion, _idReserva, _turistas);
        contadorExoneracion++;
        emit ExoneracionRegistrada(contadorExoneracion, _idReserva);
    }

    function verExoneraciones()
        public
        view
        returns (Exoneracion[] memory _resultado)
    {
        _resultado = new Exoneracion[](contadorExoneracion);
        for (uint256 i = 0; i < contadorExoneracion; i++) {
            _resultado[i] = exoneraciones[i];
        }
        return _resultado;
    }

    function verMensajeExoneraciones() public view returns (string memory) {
        return mensajeExoneracion;
    }

    function verExoneracion(uint256 _idExoneracion)
        public
        view
        returns (Exoneracion memory)
    {
        return exoneraciones[_idExoneracion];
    }
}
