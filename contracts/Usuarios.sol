// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

//Este contrato se encarga de gestionar los atrigutos (variables) y métidos (funciones)
//básicos de los 2 tipos de usuarios requeridos en DApp Guanacaste Tours: Turistas y Guías.
contract Usuarios {
    //Dueño de la agencia de turismo.
    address private duenno;

    //Listas  de direcciones de turistas y guias (Esto es para itereación y listas
    //ya que en solidity no se puede recorrer un mapping).
    address[] public listaGuiaTuristas;
    address[] public listaTuristas;

    //Arreglos (listas) de los 2 tipos de usuarios.
    mapping(address => GuiaTuristas) public guiasRegistrados;
    mapping(address => Turista) public turistasRegistrados;

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
        //uint8 que va de 0 a 255
        uint8 edad;
        bool estado;
    }

    //Estos son los registros de eventos (son como auditirias) que se registran cuando se hacen
    //cambos significativos en los registros.
    event GuiaRegistrado(address cuenta, string nombre);
    event GuiaEliminado(address cuenta);
    event TuristaRegistrado(address cuenta, string nombre);
    event TuristaEliminado(address turista);

    constructor() {
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
    {
        require(
            !guiasRegistrados[_cuenta].estado,
            "Guia de Turistas ya esta registrado"
        );
        guiasRegistrados[_cuenta] = GuiaTuristas(_cuenta, _nombre, true);
        //La función de guardar en esta lista es solo para poder hacer iteraciones en las funciones tipo view.
        listaGuiaTuristas.push(_cuenta);
        emit GuiaRegistrado(_cuenta, _nombre);
    }

    function registrarTurista(
        address _cuenta,
        string memory _nombre,
        uint8 _edad
    ) public soloGuias {
        require(
            !turistasRegistrados[_cuenta].estado,
            "Turista ya esta registrado"
        );
        turistasRegistrados[_cuenta] = Turista(_cuenta, _nombre, _edad, true);
        //La función de guardar en esta lista es solo para poder hacer iteraciones en las funciones tipo view.
        listaTuristas.push(_cuenta);
        emit TuristaRegistrado(_cuenta, _nombre);
    }

    function verGuia(address _cuenta)
        public
        view
        returns (string memory)
    {
        require(guiasRegistrados[_cuenta].estado, "Guia no existe");
        return guiasRegistrados[_cuenta].nombreCompleto;
    }

    function verTurista(address _cuenta) public view returns (Turista memory) {
        require(turistasRegistrados[_cuenta].estado, "Turista no existe");
        return turistasRegistrados[_cuenta];
    }

    //En esta función se retorna una lista de objetos tipo GuiaTuristas.
    function verGuias()
        public
        view
        soloDuenno
        returns (GuiaTuristas[] memory _resultado)
    {
        //Se crea un arreglo de objetos tipo GuiaTuristas con el tamaño de la lista de guias.
        _resultado = new GuiaTuristas[](listaGuiaTuristas.length);
        //Se recorre la listaGuiaTuristas para obtener los address y con ellos obtener el resto de la información
        //de cada guia en el mapping guiasRegistrados.
        for (uint8 i = 0; i < listaGuiaTuristas.length; i++) {
            //Solo se agregan a la lista los guias que estén activos (estado = true).
            if (guiasRegistrados[listaGuiaTuristas[i]].estado) {
                _resultado[i] = guiasRegistrados[listaGuiaTuristas[i]];
            } else {
                //Si el Guia de turistas no está activo se disminuye el contador para que no quede un espacio vacío en el arreglo.
                i--;
            }
        }
        return _resultado;
    }

    //No le agrego documentación porque es igual a la función anterior
    function verTuristas()
        public
        view
        soloGuias
        returns (Turista[] memory resultado)
    {
        resultado = new Turista[](listaTuristas.length);
        for (uint16 i = 0; i < listaTuristas.length; i++) {
            if (turistasRegistrados[listaTuristas[i]].estado) {
                resultado[i] = turistasRegistrados[listaTuristas[i]];
            } else {
                i--;
            }
        }
        return resultado;
    }

    function eliminarGuiaTurista(address _cuenta) public soloDuenno {
        //Si el estado del Guia de Tusitas es inactivo (estado = False), entonces ya está eliminado.
        require(guiasRegistrados[_cuenta].estado, "Guia no existe");
        guiasRegistrados[_cuenta].estado = false;
        emit GuiaEliminado(_cuenta);
    }

    function eliminarTurista(address _cuenta) public soloGuias {
        //Si el estado del  Tusitas es inactivo (estado = False), entonces ya está eliminado.
        require(turistasRegistrados[_cuenta].estado, "Turista no existe");
        turistasRegistrados[_cuenta].estado = false;
        emit TuristaEliminado(_cuenta);
    }
}
