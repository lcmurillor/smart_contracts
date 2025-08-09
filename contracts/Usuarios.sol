// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.30;

//Este contrato se encarga de gestionar los atrigutos (variables) y métidos (funciones)
//básicos de los 2 tipos de usuarios requeridos en DApp Guanacaste Tours: Turistas y Guías.
contract Usuarios {
    //Un Objeto de tipo GuiaTuristas con sus variables básicas.
    struct GuiaTuristas {
        address cuenta;
        string nombreCompleto;
        bool estado;
    }
    //Un Objeto de tipo Turista con sus variables básicas.
    struct Turista {
        address cuenta;
        string nombreCompleto;
        uint8 edad;
        bool estado;
    }

    //Dueño de la agencia de turismo.
    address public duenno;

    //Listas  de turistas y guias (Esto es para itereación y listas
    //ya que en solidity no se puede recorrer un mapping).
    address[] private listaGuias;
    address[] private listaTuristas;

    constructor() {
        duenno = msg.sender;
    }

    //Arreglos (listas) de los 2 tipos de usuarios.
    mapping(address => GuiaTuristas) private guiasRegistrados;
    mapping(address => Turista) private turistasRegistrados;

    //Valida que solo el dueño haga cambios.
    modifier soloDuenno() {
        require(
            msg.sender == duenno,
            "Solo el Duenno puede realizar esta accion"
        );
        _;
    }

    //Valida que solo los gúias de turistas puedan hacer cambios.
    modifier soloGuias() {
        require(
            msg.sender == duenno || guiasRegistrados[msg.sender].estado,
            "Solo el Duenno o Guias de turistas puede realizar esta accion"
        );
        _;
    }

    function registrarGuiaTurista(address _cuenta, string memory _nombre)
        public
        soloDuenno
        returns (string memory mensaje)
    {
        require(
            !guiasRegistrados[_cuenta].estado,
            "Guia de Turistas ya esta registrado"
        );
        guiasRegistrados[_cuenta] = GuiaTuristas(_cuenta, _nombre, true);
        listaGuias.push(_cuenta);
        emit GuiaRegistrado(_cuenta, _nombre);
        return "Guia de Turistas registrado con exito";
    }

    function registrarTurista(
        address _cuenta,
        string memory _nombre,
        uint8 _edad
    ) public soloGuias returns (string memory mensaje) {
        require(
            !turistasRegistrados[_cuenta].estado,
            "Turista ya esta registrado"
        );
        turistasRegistrados[_cuenta] = Turista(_cuenta, _nombre, _edad, true);
        listaTuristas.push(_cuenta);
        emit TuristaRegistrado(_cuenta, _nombre);
        return "Turista registrado con exito";
    }

    function verGuia(address _cuenta)
        public
        view
        returns (
            address cuenta,
            string memory nombre,
            bool activo
        )
    {
        GuiaTuristas memory _guia = guiasRegistrados[_cuenta];
        return (_guia.cuenta, _guia.nombreCompleto, _guia.estado);
    }

    function verTurista(address _cuenta)
        public
        view
        returns (
            address cuenta,
            string memory nombre,
            uint8 edad,
            bool activo
        )
    {
        Turista memory _turista = turistasRegistrados[_cuenta];
        return (
            _turista.cuenta,
            _turista.nombreCompleto,
            _turista.edad,
            _turista.estado
        );
    }

    function verGuias()
        public
        view
        soloDuenno
        returns (GuiaTuristas[] memory resultado)
    {
        resultado = new GuiaTuristas[](listaGuias.length);
        for (uint256 i = 0; i < listaGuias.length; i++) {
            resultado[i] = guiasRegistrados[listaGuias[i]];
        }
        return resultado;
    }

    function verTuristas()
        public
        view
        soloGuias
        returns (Turista[] memory resultado)
    {
        resultado = new Turista[](listaTuristas.length);
        for (uint256 i = 0; i < listaTuristas.length; i++) {
            resultado[i] = turistasRegistrados[listaTuristas[i]];
        }
        return resultado;
    }

    function eliminarGuiaTurista(address _cuenta)
        public
        soloDuenno
        returns (string memory mensaje)
    {
        require(guiasRegistrados[_cuenta].estado, "Guia no existe");
        guiasRegistrados[_cuenta].estado = false;
        emit GuiaEliminado(_cuenta);
        for (uint256 i = 0; i < listaGuias.length; i++) {
            if (listaGuias[i] == _cuenta) {
                //Se hace un intercambio de la posición actual con la última del arreglo
                //y luego se elimina el último elemento del arreglo.
                listaGuias[i] = listaGuias[listaGuias.length - 1];
                listaGuias.pop();
                break;
            }
        }
        return "Guia de Turistas eliminado con exito";
    }

    function eliminarTurista(address _cuenta)
        public
        soloGuias
        returns (string memory mensaje)
    {
        require(turistasRegistrados[_cuenta].estado, "Turista no existe");
        turistasRegistrados[_cuenta].estado = false;
        emit TuristaEliminado(_cuenta);
          for (uint256 i = 0; i < listaTuristas.length; i++) {
            if (listaTuristas[i] == _cuenta) {
                //Se hace un intercambio de la posición actual con la última del arreglo
                //y luego se elimina el último elemento del arreglo.
                listaTuristas[i] = listaTuristas[listaTuristas.length - 1];
                listaTuristas.pop();
                break;
            }
        }
        return "Turista eliminado con exito";
    }

    //Estos son los registros de eventos (son como auditirias) que se registran cuando se hacen
    //cambos significativos en los registros.
    event GuiaRegistrado(address cuenta, string nombre);
    event GuiaEliminado(address cuenta);
    event TuristaRegistrado(address cuenta, string nombre);
    event TuristaEliminado(address turista);
}
