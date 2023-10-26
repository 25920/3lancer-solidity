// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ThreeLancer {
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    struct Service {
        string name;
        uint256 id;
        string description;
        uint256 fee;
        uint256 intervalInDays;
        string category;
        bool available;
        address[] pastBuyers;
    }

    struct Purchased {
        uint256 id;
        uint256 serviceId;
        address buyer;
        bool delivered;
        bool continued;
    }

    mapping (address => bool) public verified;
    mapping (address => bool) public isRegistered;
    mapping (uint256 => Service) public services;
    mapping (uint256 => Purchased) public records;
    uint256 public serviceAmount;
    uint256 public tradeAmount;
    uint256 public clientAmount;

    function changeFee(uint256 _id, uint256 _fee) public {
        Service storage service = services[_id];
        service.fee=_fee;
    }

    function getServiceBuyerRecords(uint256 _id) view public returns (address[] memory) {
        return services[_id].pastBuyers;
    }

    function verifyAnAddress(address _address) public {
        require(msg.sender==deployer,"");
        require(deployer!=_address,"");
        verified[_address]=true;
    }

    function deAvailable(uint256 _id) public {
        Service storage service = services[_id];
        service.available=false;
    }

    function createAnUserAccount() public returns (uint256) {
        require(isRegistered[msg.sender]==false,"");
        require(msg.sender!=deployer,"");
        isRegistered[msg.sender]=true;
        clientAmount+=1;
        return clientAmount-1;
    }

    function createAService(
        // string[] memory _name,
        // string[] memory _description,
        // uint256[] memory _fee,
        // uint256[] memory _intervalInDays,
        // string[] memory _category,
        Service[] memory _services
    ) public returns (uint256) {
        require(msg.sender==deployer,"");
        for (uint y=0;y<_services.length;y++) {
            Service memory temp = _services[y];
            services[serviceAmount]=temp;
            serviceAmount+=1;
        }
        // service.name=_name;
        // service.id=serviceAmount;
        // service.fee=_fee;
        // service.intervalInDays=_intervalInDays;
        // service.description=_description;
        // service.category=_category;
        // service.available=true;
        // serviceAmount+=1;
        return serviceAmount-_services.length;
    }

    function buyAService(uint256 _id) public payable returns (uint256) {
        require(isRegistered[msg.sender]==true,"");
        require(verified[msg.sender]==true,"");
        Service storage buyService = services[_id];
        Purchased storage record = records[tradeAmount];
        record.id=tradeAmount;
        record.continued=false;
        if (verified[msg.sender]==true) {
            record.continued=true;
        }
        buyService.pastBuyers.push(msg.sender);
        record.delivered=false;
        record.buyer=msg.sender;
        record.serviceId=buyService.id;
        tradeAmount+=1;
        require(msg.value==buyService.fee*50/100,"");
        payable(deployer).transfer(msg.value);
        return tradeAmount-1;
    }

    function paySecondHalfAllDone(uint256 _serviceId,uint256 _recordId) public payable {
        require(isRegistered[msg.sender]==true,"");
        Service memory buyService = services[_serviceId];
        bool isThere = false;
        for (uint i = 0 ; i < buyService.pastBuyers.length;i++) {
            if (msg.sender==buyService.pastBuyers[i]) {
                isThere=true;
                break;
            }
        }
        require(isThere==true,"");
        Purchased storage record = records[_recordId];
        require(buyService.id==record.serviceId,"");
        require(msg.sender==record.buyer,"");
        require(record.delivered==false);
        record.delivered=true;
        if (record.delivered==true) {
            require(msg.value==buyService.fee*50/100,"");
            payable(deployer).transfer(msg.value);
            if (record.continued==true) {
                
            } else {
                verified[msg.sender]=false;
                record.continued=false;
            }
        }
    }

    function allAvailableService(
        ) public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            if (item.available == true ) {
                allEverCreated[i]=item;
            }
        }
        if (allEverCreated.length == serviceAmount) {
            return allEverCreated;
        } else {
            Service[] memory left = new Service[](allEverCreated.length);
            for (uint i  =0;i<allEverCreated.length;i++) {
                left[i]=allEverCreated[i];
            }
            return left;
        }
    }

    function allService(
        ) public view returns (Service[] memory) {
        require(msg.sender==deployer,"");
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            allEverCreated[i]=item;
        }
        return allEverCreated;
    }

    function everyPurchasedData(
        ) public view returns (Purchased[] memory) {
        require(tradeAmount>0,"");
        Purchased[] memory allPurchase = new Purchased[](tradeAmount);
        for (uint i  =0;i<tradeAmount;i++) {
            Purchased memory record = records[i];
            allPurchase[i]=record;
        }
        return allPurchase;
    }
}