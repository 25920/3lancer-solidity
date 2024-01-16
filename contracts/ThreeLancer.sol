// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract ThreeLancer {
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == deployer);
        _;
    }

    modifier notOwner() {
        require(msg.sender != deployer);
        _;
    }

    struct Service {
        string name;
        uint256 id;
        string description;
        uint256 fee;
        uint256 intervalInDays;
        bool available;
        address[] pastBuyers;
    }

    struct Purchased {
        uint256 id;
        uint256 serviceId;
        address buyer;
        bool delivered;
        string[] data;
    }

    mapping (uint256 => Service) public services;
    mapping (uint256 => Purchased) public records;
    mapping (address => uint256[]) public verified;
    uint256 public serviceAmount;
    uint256 public tradeAmount;

    function verifyUser(address _address, uint256[] memory _ids) public {
        // only allow user to buyer what both of us (msg.sender||deployer and the buyer) aggree on
        require(msg.sender==deployer&&msg.sender!=_address,"");
        for (uint j =0;j<_ids.length;j++) {
            verified[_address][verified[_address].length]=_ids[j];
        }
    }

    function ifVerifiedOnId(uint256 _id) notOwner public view returns (bool) {
        uint256[] memory allIds = verified[msg.sender];
        bool k = false;
        for (uint h =0;h<allIds.length;h++){
            if (allIds[h]==_id) {
                k = true;
                break;
            }
        }
        return k;
    }

    function upfrontHalfofEachServicesCost(uint256[] memory _serviceIds) notOwner public payable returns (uint256) {
        uint256 cost;
        for (uint f = 0;f < _serviceIds.length;f++) {
            require(ifVerifiedOnId(_serviceIds[f])==true,"");
            Service storage newProject = services[_serviceIds[f]];
            require(newProject.available==true,"");
            Purchased storage newRecord = records[tradeAmount];
            newRecord.id = tradeAmount;
            newProject.pastBuyers.push(msg.sender); // can be duplicate
            newRecord.delivered=false;
            newRecord.buyer=msg.sender;
            newRecord.serviceId=_serviceIds[f];
            cost+=newProject.fee*50/100;
            tradeAmount+=1;
        }
        require(msg.value==cost,"");
        payable(deployer).transfer(msg.value);
        return tradeAmount-_serviceIds.length;
    }

    function updateMappingVerified(uint256 _singleTargetId) notOwner public view returns (uint256[] memory) {
        uint256[] memory map = verified[msg.sender];
        require(ifVerifiedOnId(_singleTargetId)==true,"");
        uint256[] memory newMap = new uint256[](verified[msg.sender].length-1);
        bool passed=false;
        for (uint e=0;e<map.length;e++) {
            if (map[e]!=_singleTargetId){
                newMap[newMap.length]=map[e];
            } else {
                if (passed==true) {
                    newMap[newMap.length]=map[e];
                } else {
                    passed=true;
                }
            }
        }
        return newMap;
    }

    function payOneServicesSecondHalf(uint256 _id) notOwner public payable {
        require(ifVerifiedOnId(_id)==true,"");
        Purchased storage oldRecord = records[_id];
        require(msg.sender==oldRecord.buyer,"");
        require(oldRecord.delivered==false,"");
        oldRecord.delivered=true;
        require(msg.value==services[oldRecord.serviceId].fee*50/100,"");
        payable(deployer).transfer(msg.value);
        verified[msg.sender]=updateMappingVerified(_id);
    }

    function changeDetail(uint256 _id, uint256 _fee,string memory _desp, string memory _title, uint256 _d) onlyOwner public {
        Service storage service = services[_id];
        service.fee=_fee;
        service.intervalInDays=_d;
        service.name=_title;
        service.description=_desp;
    }

    function getServiceBuyerRecords(uint256 _id) onlyOwner view public returns (address[] memory) {
        return services[_id].pastBuyers;
    }

    function deAvailable(uint256 _id) onlyOwner public {
        Service storage service = services[_id];
        require(service.available==true,"");
        service.available=false;
    }

    function reAvailable(uint256 _id) onlyOwner public {
        Service storage service = services[_id];
        require(service.available==false,"");
        service.available=true;
    }

    function createServices(
        Service[] memory _services
    ) onlyOwner public returns (uint256) {
        for (uint y=0;y<_services.length;y++) {
            Service memory temp = _services[y];
            // always make sure the id is correct
            require(
                temp.id==serviceAmount&&temp.available==true,""
            );
            services[serviceAmount]=temp;
            serviceAmount+=1;
        }
        return serviceAmount-_services.length;
    }

    function addData(
        uint256 _recordId,
        string[] memory _imgs) onlyOwner public {
        Purchased storage record = records[_recordId];
        for (uint h = 0 ; h< _imgs.length;h++) {
            record.data.push(_imgs[h]);
        }
    }

    function allAvailableService(
        ) public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        uint256 f = 0;
        for (uint i=0;i<serviceAmount;i++) {
            Service memory item = services[i];
            if (item.available == true ) {
                allEverCreated[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverCreated;
        } else {
            Service[] memory left = new Service[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverCreated[i];
            }
            return left;
        }
    }

    function allService(
        ) onlyOwner public view returns (Service[] memory) {
        Service[] memory allEverCreated = new Service[](serviceAmount);
        for (uint i  =0;i<serviceAmount;i++) {
            Service memory item = services[i];
            allEverCreated[i]=item;
        }
        return allEverCreated;
    }

    function everyPurchasedData() onlyOwner public view returns (Purchased[] memory) {
        Purchased[] memory allPurchase = new Purchased[](tradeAmount);
        for (uint i  =0;i<tradeAmount;i++) {
            Purchased memory record = records[i];
            allPurchase[i]=record;
        }
        return allPurchase;
    }

    function allPurchaseByServiceId(
        uint256 _id
    ) onlyOwner public view returns (Purchased[] memory) {
        Purchased[] memory allEverBought = new Purchased[](tradeAmount);
        uint256 f = 0;
        for (uint i=0;i<tradeAmount;i++) {
            Purchased memory item = records[i];
            if (item.serviceId == _id ) {
                allEverBought[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverBought;
        } else {
            Purchased[] memory left = new Purchased[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverBought[i];
            }
            return left;
        }
    }

    function allPurchaseByAddress(
        address _address
    ) public view returns (Purchased[] memory) {
        require(msg.sender==_address||msg.sender==deployer,"");
        Purchased[] memory allEverBought = new Purchased[](tradeAmount);
        uint256 f = 0;
        for (uint i=0;i<tradeAmount;i++) {
            Purchased memory item = records[i];
            if (item.buyer == _address ) {
                allEverBought[i]=item;
                f+=1;
            }
        }
        if (f == serviceAmount) {
            return allEverBought;
        } else {
            Purchased[] memory left = new Purchased[](f);
            for (uint i  =0;i<f;i++) {
                left[i]=allEverBought[i];
            }
            return left;
        }
    }
}