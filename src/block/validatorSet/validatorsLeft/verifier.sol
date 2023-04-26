//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// 2019 OKIMS
//      ported to solidity 0.6
//      fixed linter warnings
//      added requiere error messages
//
//
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.11;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() internal pure returns (G2Point memory) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(
            20491192805390485299153009773594534940189261866228447918068658471970481763042,
            9383485363053290200918347156157836566562967994039712273449902621266178545958
        );

        vk.beta2 = Pairing.G2Point(
            [4252822878758300859123897981450591353533073413197771768651442665752259397132,
             6375614351688725206403948262868962793625744043794305715222011528459656738731],
            [21847035105528745403288232691147584728191162732299865338377159692350059136679,
             10505242626370262277552901082094356697409835680220590971873171140371331206856]
        );
        vk.gamma2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = Pairing.G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.IC = new Pairing.G1Point[](37);
        
        vk.IC[0] = Pairing.G1Point( 
            15223818384046161611086815810532403082300369704955865511121043310001935913675,
            2923246250784032067602890569674724728742385927561953842370309158247654805686
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            16297754427881278542047044409209705556286786271258067153381766964879233691377,
            9725945643284956455180939112960898956008507448821036493392087816727274976703
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            9439297585140090746701661430206635826206144898816021686347266778713380558210,
            3220357580131070430867518758921708968030616704274359191913084422102159350915
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            490764872166184430349090291600822725363356425678162229970681041843717522475,
            17197518696876422661577230817128103038453810324546668503930022255437944739941
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            20390715863328953159549351227823197480540545382048769645258051785729139631419,
            1709143831472626562338471527998695335844283644882042385667987786202879889866
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            16446046199290790822750223416953492289663289765123127221096327845870539528980,
            16759483872047547457265661641065371471303494629086339397431803595908851758367
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            407941547106542707414625859644144554223694518066647604135319500142711116100,
            21203229018060075016240658192106105223063363959899845914680799910298981188348
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            16624802396099114714685556213734444438355746445001677250388400577429357182383,
            2089169482963039630926771665909543685954120891503997623201915847951171328496
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            8981439511827987535835243761015246271550584621449051788305085305961039922161,
            8360559608761542402960839080567309151170305345642061579577913038758624280376
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            20938689005367085807738541905284798457420871948647824686454328763413004790742,
            21437581583144738727570980024798899667951583825312369554859137545498151067259
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            11243040396281796597032751235401900015757167880420807552487971572280809888946,
            1514223299861896552868886822938489763011656623052692670801481423622849916259
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            2222143780491615135580223566636800327969942786605218296167342439828023980873,
            10149401042825597200954622431914512226564895290447170624517684722698960880543
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            13939594799361352107474542727865977191431975624995589230429015993073732273687,
            16551468228990664690057634456054557061210018948588173219847602058811430746334
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            9196758044334135172268415961258023280542682535039457159597009445574284461603,
            5140321438001247405279666298560421495890862429735307964486650787088334356933
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            9102035572508797211235375648475688172375502997019892107745852260726567497928,
            11360319481396983718294721828109264884169521053128928448519363675163623275417
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            15273348987138024234120715686604040247577220316462898553427470264520395136360,
            6718540354734759734012638039522981910047368148262434448453571636563022421522
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            7271325038682067834250727180621668072873284884752725634147498901409153373030,
            20263596317435200909479895566356544872686044213580325176446000163777862575098
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            3705599246038467018508124845302090926136290728024123151222387733065400744989,
            18921636197712918551481017875450412599297518676049826641880335494747120077459
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            2920639758960687131227440337359092731924337089438011831641082366622640972829,
            19652614032129995096550640785998011581413504955686851971189949026855064747036
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            5056215861190534080261741831968393566435097520532763189485366662099903804989,
            6851735272492971747672418480518377394298952918317191077680595213738989304032
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            1426277044326899098024491192964195342861839502261303901243601450963647428959,
            7692363535877329866491520263740478852213323739161354580031950656781892632457
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            3138312253512838988158941323787227409336251476361492083410652995471057955426,
            21666257061613361488654037272993193408179622124266278916016391249070641459241
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            11640859436257776245617382239101560568354638146306666736852118354578998672768,
            11579903082113609190870649108917903311426230697843909364575684112602470784634
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            15548523951895884392076907391263376995122869660867296446505842745839877789080,
            21097319701747109588852845070751355519230059429298300456968864568725077038839
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            7539130536279019858667501458714251117047287873281945264960969293956329253229,
            12764614449723052986838834820387399215797870190773194902888777098761588267247
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            15099213615580484558736606185792004799167258678592050428170708123496072682874,
            19169575231093844052882403813342847984375511291599463306616819046635555764534
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            11230212520482833005596380233490852515866129091193221119052374197897614086196,
            20588401133177384304236657321363272320468079830438466643656199956313766945919
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            21445526163078540936753259856520147389926911711701190095988126679645812289867,
            12049730792098058322689550625766016783733311503940255783547941096035741051656
        );                                      
        
        vk.IC[28] = Pairing.G1Point( 
            21026320951954189405866236965859650280154328685890930922389014389196806761359,
            15848346866555411580694641493992228659481810377553459022109269657799883285580
        );                                      
        
        vk.IC[29] = Pairing.G1Point( 
            1206553514163134197637916564053799769517348795646478923519318889265654835611,
            19051111375514684276588502148499100220142513106629977177939345652772244989219
        );                                      
        
        vk.IC[30] = Pairing.G1Point( 
            7944594215099323784303436764166397803699159367091214627942140299670716180132,
            17612203617767635157320658950363080278696033320727352704205193730841549211225
        );                                      
        
        vk.IC[31] = Pairing.G1Point( 
            8286708129474071483036234874334854381013782483202175176068370595316054662054,
            8983935801051823351304923280293328877032703943842065517391901570538166848298
        );                                      
        
        vk.IC[32] = Pairing.G1Point( 
            11360449035946955799934835808293250700146248160556369651242574736791808149952,
            7373584376322600949592837144658428020709852045888786893829972825072859456731
        );                                      
        
        vk.IC[33] = Pairing.G1Point( 
            637021618186524520499568633832651362226218385851516346923430132114829188277,
            1380210291025878943761814576907192791999210946534252545313594185552770493108
        );                                      
        
        vk.IC[34] = Pairing.G1Point( 
            10631648660566751940047124474888187702582293841692476509107388667087210941264,
            11733588935316753544387058239395882355837222834717059887837992964707914819612
        );                                      
        
        vk.IC[35] = Pairing.G1Point( 
            3774912529132034297373143696395854356368585395558725540481652654607969565301,
            12247891838630407367705870162534513584320368297540031549477520763006508768045
        );                                      
        
        vk.IC[36] = Pairing.G1Point( 
            18537478594599979927733994877602050224249644999862684119378363537060997770546,
            21713085621273616336751731703824122096505685830656968877759430957624006987526
        );                                      
        
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    /// @return r  bool true if proof is valid
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[36] memory input
        ) public view returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
