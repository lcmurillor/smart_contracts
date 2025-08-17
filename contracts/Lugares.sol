// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Realizamos el import para acceder a los guias de turistas
import "./Usuarios.sol";

//Este contrato se encarga de gestionar los atrigutos (variables) y métidos (funciones)
//básicos de los lugares requeridos en DApp Guanacaste Tours: Turistas y Guías.
contract Lugares {

    
    //Esto permite hacer referencia a la totalidad del contrato
    //Se hace una instancia del contrato "Usuarios" dentro de este contrato.
    Usuarios public usuariosContrato;

    //Dueño de la agencia de turismo.
    address public duenno;

    struct Lugar {
        string nombre;
        uint precio;
        uint cupos;
        address guiaTurustas;
        bool estado;
    }

    Lugar[] public listaLugares;


    //Dentro del constructor realizamos la iniciación del Contrato relacionado con los usuarios
    //y se le asigna una dirreción al contrato. (es un address que hace referencia al contrato
    //en su totalidad, con confundir con la dirreción del dueño, un guía a turista).
    constructor(address _usuariosContrato) {
        usuariosContrato = Usuarios(_usuariosContrato);
        duenno = msg.sender;
    }

    //Valida que solo el dueño haga cambios.
    modifier soloDuenno() {
        require(
            msg.sender == duenno,
            "Solo el Duenno puede realizar esta accion"
        );
        _;
    }


    function obtenerGuia(address _cuenta) public  view  returns (Usuarios.GuiaTuristas memory){
        return usuariosContrato.verGuia(_cuenta);
    }

    //Valida que solo los gúias de turistas puedan hacer cambios.
    modifier soloGuias() {
        require(
            msg.sender == duenno || obtenerGuia(msg.sender).estado,
            "Solo el Duenno o Guias de turistas puede realizar esta accion"
        );
        _;
    }

    //ContratoA.Registro memory reg = contratoA.obtenerRegistro(index);

    function registrarLugar(
        string memory _nombre,
        uint _precio,
        uint _cupos,
        address _guiaTuristas
    ) public soloDuenno returns (string memory) {
        for (uint256 i = 0; i < listaLugares.length; i++) {
            //keccak256(abi.encodePacked(string)) lo que hace es presear los tipos de datos
            //ya que en esta compración un es un String Storage y el otro String memory y da error.
            if (
                keccak256(abi.encodePacked(listaLugares[i].nombre)) ==
                keccak256(abi.encodePacked(_nombre))
            ) {
                return "El lugar ya se encuentra registrado";
            }
        }
        require(
            obtenerGuia(_guiaTuristas).estado,
            "Deber ser un guia registrado"
        );
        Lugar memory _lugar = Lugar(
            _nombre,
            _precio,
            _cupos,
            _guiaTuristas,
            true
        );
        listaLugares.push(_lugar);
        emit LugarRegistrado(_nombre);
        return "Guia de Turistas registrado con exito";
    }

    function verLugar(string memory _nombre)
        public
        view
        returns (Lugar memory lugar)
    {
        Lugar memory _lugar;
        for (uint256 i = 0; i < listaLugares.length; i++) {
            if (
                keccak256(abi.encodePacked(listaLugares[i].nombre)) ==
                keccak256(abi.encodePacked(_nombre))
            ) {
                _lugar = listaLugares[i];
            }
        }
        return (_lugar);
    }

    function verLugares() public view returns (Lugar[] memory resultado) {
        resultado = new Lugar[](listaLugares.length);
        for (uint256 i = 0; i < listaLugares.length; i++) {
            resultado[i] = listaLugares[i];
        }
        return resultado;
    }

    function eliminarLugar(string memory _nombre)
        public
        soloDuenno
        returns (string memory mensaje)
    {
        for (uint256 i = 0; i < listaLugares.length; i++) {
            if (
                keccak256(abi.encodePacked(listaLugares[i].nombre)) ==
                keccak256(abi.encodePacked(_nombre))
            ) {
                //Se hace un intercambio de la posición actual con la última del arreglo
                //y luego se elimina el último elemento del arreglo.
                emit LugarEliminado(listaLugares[i].nombre);
                listaLugares[i] = listaLugares[listaLugares.length - 1];
                listaLugares.pop();
                break;
            }
        }
        return "Lugar eliminado con exito";
    }

    //Estos son los registros de eventos (son como auditirias) que se registran cuando se hacen
    //cambos significativos en los registros.
    event LugarRegistrado(string nombre);
    event LugarEliminado(string nombre);
}
