// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CampanniaDeDonacionesConMeta {

    address private owner; // Cuenta del creador de la campaña
    address private beneficiario; // Cuenta del beneficiario de la campaña
    uint private meta; // Meta en Wei a alcanzar para que la campaña sea exitosa
    uint private fechaLimite; // Tiempo límite de la campaña
    uint private totalRecaudado; // Total recaudado hasta el momento
    bool private fondosRetirados; // Si los fondos ya fueron retirados

    mapping(address => uint) private donaciones; // Lista de las cuentas con sus donaciones

    constructor(address addressBeneficiario, uint metaWei, uint segundos) {
        beneficiario = addressBeneficiario;
        meta = metaWei;
        fechaLimite = block.timestamp + segundos;
        fondosRetirados = false;
        owner = msg.sender;
    }

    // Función para donar ETH
    function donar() public payable {
        require(msg.sender != owner && msg.sender != beneficiario, "Solo las cuentas donadoras pueden donar");
        require(block.timestamp < fechaLimite, "La campannia ha terminado");
        require(msg.value > 0, "Debes donar ETH");

        donaciones[msg.sender] += msg.value;
        totalRecaudado += msg.value;
    }

    // Función para retirar fondos si se cumple la meta
    function retirarFondos() public {
        require(msg.sender == beneficiario, "Solo el beneficiario puede retirar");
        require(block.timestamp >= fechaLimite, "La campannia no ha terminado");
        require(totalRecaudado >= meta, "Meta no alcanzada");
        require(!fondosRetirados, "Fondos ya retirados");

        fondosRetirados = true;

        // Transferir ETH a la cuenta Beneficiario
        (bool exito, ) = payable(beneficiario).call{value: address(this).balance}("");
        require(exito, "Fallo al transferir fondos");
    }

    // Función para reembolsar donaciones si no se alcanzó la meta
    function reembolsar() public {
        require(block.timestamp >= fechaLimite, "La campannia no ha terminado");
        require(totalRecaudado < meta, "La meta fue alcanzada");
        require(donaciones[msg.sender] > 0, "No tienes donaciones que reclamar");

        uint monto = donaciones[msg.sender];
        donaciones[msg.sender] = 0;

        (bool exito, ) = payable(msg.sender).call{value: monto}("");
        require(exito, "Fallo al reembolsar");
    }

    // Ver el organizador de la campaña
    function verOrganizador() public view returns (address) {
        return owner;
    }

    // Ver el beneficiario de la campaña
    function verBeneficiario() public view returns (address) {
        return beneficiario;
    }

    // Ver tiempo restante en segundos
    function verTiempoRestante() public view returns (uint) {
        if (block.timestamp >= fechaLimite) {
            return 0;
        } else {
            return fechaLimite - block.timestamp;
        }
    }

    // Ver estado de la campaña
    function verEstadoCampana() public view returns (string memory) {
        if (block.timestamp < fechaLimite) {
            return "activa"; // Si la camapaña sigue activa
        } else if (totalRecaudado >= meta) {
            return "exitosa"; // Si la campaña alcanzó la meta
        } else {
            return "fallida"; // Si la campaña falló
        }
    }

    // Ver la meta a alcanzar
    function verMeta() public view returns (uint) {
        return meta;
    }

    // Ver cuánto ha donado una dirección
    function verDonacion(address donante) public view returns (uint) {
        return donaciones[donante];
    }

    // Ver el total recaudado
    function verTotalRecaudado() public view returns (uint) {
        return totalRecaudado;
    }
}
