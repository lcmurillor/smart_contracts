// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Realizamos el import para acceder a los turistas
import "./Usuarios.sol";

//Realizamos el import para acceder a los lugares
import "./Lugares.sol";

contract Resennas {
    Usuarios private usuariosContrato;
    Lugares private lugaresContrato;

    mapping(uint256 => Resenna) private resennas;
    uint256 private contadorResennas;

    struct Resenna {
        string nombreLugar;
        address turista;
        uint8 puntaje; //del 1 al 10
        string comentario;
        bool estado;
    }

    event ResennaRegistrada(uint256 id, string nombreLugar);
    event ResennaEliminada(uint256 id, string nombreLugar);

    constructor(address _usuariosContrato, address _lugaresContrato) {
        usuariosContrato = Usuarios(_usuariosContrato);
        lugaresContrato = Lugares(_lugaresContrato);
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

    function registrarResenna(
        string memory _nombreLugar,
        address _turista,
        uint8 _puntaje,
        string memory _comentario
    ) public {
        require(
            bytes(_nombreLugar).length > 0,
            "Debe definir el lugar que sesea calificar"
        );
        require(
            obtenerLugar(_nombreLugar).estado,
            "Deber ser un lugar registrado"
        );
        require(
            obtenerTurista(_turista).estado,
            "Deber ser un turista registrado"
        );
        require(
            _puntaje >= 1 && _puntaje <= 10,
            "Debe ser un puntaje entre 1 y 10"
        );
        resennas[contadorResennas] = Resenna(
            _nombreLugar,
            _turista,
            _puntaje,
            _comentario,
            true
        );
        contadorResennas++;
        emit ResennaRegistrada(contadorResennas, _nombreLugar);
    }

    function verResernnaPorID(uint256 _idResenna)
        public
        view
        returns (Resenna memory)
    {
        require(resennas[_idResenna].estado, "Esta reseva no existe");
        return resennas[_idResenna];
    }

    function verResernnasPorNombreLugar(string memory _nombreLugar)
        public
        view
        returns (Resenna[] memory _resultado)
    {
        require(bytes(_nombreLugar).length > 0, "Debe ingresar el nombre del lugar que sea ver las resennas");
        require(obtenerLugar(_nombreLugar).estado, "Debe ser un lugar registado");
        //Contamos la cantidad total de reseñas que exiten para el lugar que seamos consultar.
        uint256 _totalResennas = 0;
        for (uint256 i = 0; i < contadorResennas; i++) 
        {
            if ( keccak256(abi.encodePacked(resennas[i].nombreLugar)) ==
                keccak256(abi.encodePacked(_nombreLugar)) && resennas[i].estado) {
                _totalResennas++;
            }
        }

        //Creamos el arreglo de reseñas con la cantidad previamente definida.
        _resultado = new Resenna[](_totalResennas);
        uint256 _contador = 0;
        //Cargamos ese arreglo con las reseñas con que correspondan al mismo lugar y que esten activas.
        for (uint256 i = 0; i < contadorResennas; i++) 
        {
            if ( keccak256(abi.encodePacked(resennas[i].nombreLugar)) ==
                keccak256(abi.encodePacked(_nombreLugar)) && resennas[i].estado) {
                _resultado[_contador] = resennas[i];
                _contador++;
            }
        }
        return _resultado;
    }

    function eliminarResenna(uint256 _idResenna) public soloGuias {
        require(resennas[_idResenna].estado, "Esta resenna no existe");
        resennas[_idResenna].estado = false;
        emit ResennaEliminada(_idResenna, resennas[_idResenna].nombreLugar);
    }

}
