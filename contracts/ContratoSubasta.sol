// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ContratoSubasta {
    bool public subastaActiva;
    bool public subastaFinalizada;

    struct Subasta {
        address administrador;
        string articulo;
        uint256 montoBase;
        uint256 tiempoLimite;
    }

    Subasta public subasta;

    struct MejorOferta {
        address ofertante;
        uint256 monto;
    }

    MejorOferta public mejorOferta;

    mapping(address => bool) public oferentesRegistrados;
    mapping(address => uint256) public ofertas;

    event SubastaCreada(
        string articulo,
        uint256 montoBase,
        uint256 duracionSegundos
    );
    event OferenteRegistrado(address cuenta);
    event NuevaOferta(address ofertante, uint256 monto);
    event SubastaFinalizada(address ganador, uint256 montoFinal);

    constructor() {
        subasta.administrador = msg.sender;
        subastaActiva = false;
    }

    modifier soloAdministrador() {
        require(
            msg.sender == subasta.administrador,
            "Solo el administrador puede realizar esta accion"
        );
        _;
    }
    modifier soloOferentes() {
        require(
            oferentesRegistrados[msg.sender],
            "No estas registrado como oferente"
        );
        _;
    }

    modifier subastaEnCurso() {
        require(subastaActiva, "La subasta no esta activa");
        require(
            block.timestamp < subasta.tiempoLimite,
            "La subasta ha expirado"
        );
        _;
    }

    function crearSubasta(
        string memory _articulo,
        uint256 _montoBase,
        uint256 _duracionSegundos
    ) public soloAdministrador {
        require(!subastaActiva, "Ya hay una subasta activa");
        subasta.articulo = _articulo;
        subasta.montoBase = _montoBase;
        subasta.tiempoLimite = block.timestamp + _duracionSegundos;
        subastaActiva = true;
        subastaFinalizada = false;
        mejorOferta = MejorOferta({ofertante: address(0), monto: 0});
        emit SubastaCreada(_articulo, _montoBase, _duracionSegundos);
    }

    function registrarseComoOferente() public {
        require(!oferentesRegistrados[msg.sender], "Ya estas registrado");
        oferentesRegistrados[msg.sender] = true;
        emit OferenteRegistrado(msg.sender);
    }

    function ofertar() public payable subastaEnCurso soloOferentes {
        require(
            msg.value >= subasta.montoBase,
            "Debes ofertar al menos el monto base"
        );
        require(
            msg.value > mejorOferta.monto,
            "Tu oferta debe superar la actual"
        );
        if (mejorOferta.monto > 0) {
            payable(mejorOferta.ofertante).transfer(mejorOferta.monto);
        }
        ofertas[msg.sender] = msg.value;
        mejorOferta = MejorOferta(msg.sender, msg.value);
        emit NuevaOferta(msg.sender, msg.value);
    }

    function verOfertaActual() public view returns (address, uint256) {
        return (mejorOferta.ofertante, mejorOferta.monto);
    }

    function finalizarSubasta() public {
        require(subastaActiva, "No hay subasta activa");
        require(
            subasta.administrador == msg.sender ||
                block.timestamp >= subasta.tiempoLimite,
            "No tienes permiso para finalizar"
        );
        subastaActiva = false;
        subastaFinalizada = true;
        if (mejorOferta.ofertante != address(0)) {
            payable(subasta.administrador).transfer(mejorOferta.monto);
        }
        emit SubastaFinalizada(mejorOferta.ofertante, mejorOferta.monto);
    }
}
