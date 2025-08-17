// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Realizamos el import para acceder a los guias de turistas
import "./Usuarios.sol";

//Este contrato se encarga de gestionar los atrigutos (variables) y métidos (funciones)
//básicos de los lugares requeridos en DApp Guanacaste Tours: Turistas y Guías.
contract Lugares {
    //Esto permite hacer referencia a la totalidad del contrato
    //Se hace una instancia del contrato "Usuarios" dentro de este contrato.
    Usuarios private usuariosContrato;

    mapping(uint256 => Lugar) private lugares;
    uint8 private contadorLugares;

    struct Lugar {
        string nombre;
        uint16 precio;
        uint8 cupos;
        address guiaTuristas;
        bool estado;
    }

    //Estos son los registros de eventos (son como auditirias) que se registran cuando se hacen
    //cambos significativos en los registros.
    event LugarRegistrado(string nombre);
    event LugarEliminado(string nombre);

    //Dentro del constructor realizamos la iniciación del Contrato relacionado con los usuarios
    //y se le asigna una dirreción al contrato. (es un address que hace referencia al contrato
    //en su totalidad, con confundir con la dirreción del dueño, un guía a turista).
    constructor(address _usuariosContrato) {
        usuariosContrato = Usuarios(_usuariosContrato);
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

    function registrarLugar(
        string memory _nombre,
        uint16 _precio,
        uint8 _cupos,
        address _guiaTuristas
    ) public soloDuenno returns (string memory) {
        //Realiza las validaciones para confirmar que se cumplen los requerimientos
        //antes de ingresar un nuevo lugar.
        require(
            obtenerGuia(_guiaTuristas).estado,
            "Deber ser un guia registrado"
        );
        require(_cupos > 0, "Debe tener al menos 1 cupo");
        require(_precio > 0, "Debe tener un precio mayor a 0");
        require(bytes(_nombre).length > 0, "Debe tener un nombre");
        require(
            _guiaTuristas != address(0),
            "Debe tener un guia de turistas asociado"
        );
        //Amenta el contador global de la cantidad de lugares y procede a agregar 
        //un lugar en el mapping asignando el indice como clave.
        contadorLugares++;
        lugares[contadorLugares] = Lugar(
            _nombre,
            _precio,
            _cupos,
            _guiaTuristas,
            true
        );

        emit LugarRegistrado(_nombre);
        return "Guia de Turistas registrado con exito";
    }

    function verLugar(string memory _nombre)
        public
        view
        returns (Lugar memory)
    {
        //Recorre el mapping para encontrar el lugar con el nombre indicado.
        Lugar memory _lugar;
        for (uint8 i = 0; i < contadorLugares; i++) {
            //Se hace uso de la función keccak256 para hacer una comparación de cadenas.
            //Esto porque el resulatado del mapping es un string Storage y el del parámetro 
            //un string memory y es necesario parsear para que sean de un formato similar
            //y poder ser comparados.
            if ( keccak256(abi.encodePacked(lugares[i].nombre)) ==
            keccak256(abi.encodePacked(_nombre))) {
                _lugar = lugares[i];
            }
        }
        return (_lugar);
    }

    function verLugares() public view returns (Lugar[] memory _resultado) {
        //A la hora de ver lo lugares, se espera solo mostrar los lugares registrados
        //en estado activos (Estado = true). Así que lo que hacemos es contar la cantidad
        //de lugares activos para saber el tamaño del arrego que debemos mostrar. 
        uint8 _totalActivos = 0;
        for (uint8 i = 0; i < contadorLugares; i++) {
            lugares[i].estado ? _totalActivos++ : _totalActivos;
        }
        //Una vez definido el arreglo, recorremos el mapping y a este le asignamos solo
        //los lugares con activos (Estado = true). 
        _resultado = new Lugar[](_totalActivos);
          uint8 _contador = 0;
        for (uint8 i = 0; i < contadorLugares; i++) {
            if (lugares[i].estado) {
                _resultado[_contador] = lugares[i];
                _contador ++;
            }
        }
        return _resultado;
    }

    function eliminarLugar(string memory _nombre)
        public
        soloDuenno
        returns (string memory mensaje)
    {
        for (uint8 i = 0; i < contadorLugares; i++) {
           if ( keccak256(abi.encodePacked(lugares[i].nombre)) ==
            keccak256(abi.encodePacked(_nombre))) {
                lugares[i].estado = false;
                emit LugarEliminado(_nombre);
            }
        }
        return "Lugar eliminado con exito";
    }
}
