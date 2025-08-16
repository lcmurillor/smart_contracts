// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract AlquilerVehiculos {
    address immutable propietario;

    event registrarAlquiler(address alquilador, uint256 monto);

    constructor() {
        propietario = msg.sender;
    }

    function alquilarVehiculo() public payable {
        require(msg.value >= 0.05 ether, "El monto minimo es de 0.05 ETH");
        emit registrarAlquiler(msg.sender, msg.value);
    }

    function verBalance() public view returns (uint256 _balance){
        return address(this).balance;
    }

    function retirarFondos() public payable  {
        require(msg.sender == propietario, "Solo el propietrio puede retirar fondos");
        payable(propietario).transfer(address(this).balance);
    }
}
