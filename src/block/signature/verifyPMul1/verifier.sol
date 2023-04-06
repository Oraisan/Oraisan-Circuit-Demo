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
pragma solidity ^0.8.0;
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
        vk.IC = new Pairing.G1Point[](33);
        
        vk.IC[0] = Pairing.G1Point( 
            13531047619416189794554033760145437707102158885228418631093404031517369816961,
            1426036073743186673385485747232753311823574799360893562084663333774080886073
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            11086781355231302832574740571777322676021000991425378658228231732847440496781,
            13221604581619383048799217603946131465466335092490126469424695328537090387321
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            7637902807473879989923780305835948598966740462436739557631319842870868830862,
            12696626363131363577544095424207752541883522431359764492335558123396574140486
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            10760339002878284254233905312109864746580108935619973192473407092889760883415,
            12257969662007358737476674395372840056615086275433538523106682569475816443234
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            9170046937425743782283479531259657901432887769483782552655921403399461522230,
            8410527286376620606817262673582237800208329926201330488025805359025690944007
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            6733881421499097356270619119392935340934587534512266818658167411758772223289,
            20013919613021519307638781887265227939983386792231720800831040305114951675186
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            9317189257733787813734022545821517733937579969251743295325904249121100733350,
            10524088578622255871859958735343266276924146489402504657486652398981364215843
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            13928922507534451449253771945524939358821460955962881605755236263997982891399,
            19009861123495897474981122227244454840613798296855825244802646912648061446042
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            11390401287082756364119117077436712864778257562725311486890107548026751417356,
            11477856353974784674835229719089990447808786802761003349669067914919660502087
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            4673074390783570804192135829170143362782200778941882448514038837998671993377,
            18021774288967299454731327222072267922092175925546934944977049700248727088751
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            21351828990275090630156392941199108125771824144519565954776748671557217458592,
            2897042060414978745983161504185004529350519426592868494795694654801727856189
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            14961567612754323228871071126132618603883124022327207134219888127412523362242,
            13877453846134469981809753675271301893588572696062804866833603264453463622590
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            14785422387687837205198547256823105955669302854770748907172190438654684652823,
            15906324577340846862938240474734362377342945472034292088527227074246884917726
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            3669918282770181068588881670104900328317905991745090876168015446284373007044,
            16472746688222662812933760829325456042816442682455623825438129146169818666960
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            9168932755653211557020311499638781240830305583580703870548708947263268448772,
            6474369214557715532190922960470759456936483595651428764490497271574142763834
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            6108931054218993853046205890512818887779803562679046476824942145208891654791,
            3105219177371634082672066477507816313696291147734966992940240222191358243847
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            15849120350283818949800267395900282339201706214746930319990090229529154478366,
            13009547918656854629175246191148758670541726993278032546064057516489060707975
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            8622248468363835444933842646609452144680967718008829216594673110004651945723,
            5907769652102468185776820042729925306834674603523112139454390780614970935756
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            16726062384506605810906992698613251629313491091832513937925636041452757075844,
            3348810588415448657702449391549405942222573801389538637686406362933068318078
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            18276928790958334575554708708554192453827535261748222228127977640206647606321,
            5563496021164732060558598482426560132352810144591056901113524095471846836973
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            9189923346062290435510732557368535620891665826221081641552691101123683475993,
            648709039087373544222272083773534112695278564607762572561505540719316812249
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            14593919943673704915299234229265794324348311643015867061728807737314594761367,
            13999040646445550414080412041659787176411868964277941852416090815907491098829
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            15792019298424456766873564823711336691530703571362800187065002132822420292935,
            20556032435382461783020672762716962153643879396811158570744423631239611357234
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            5973761371824833233853333722959508907390676983768793541796925770207230933747,
            21314275014056597461100352188792300586025863993483173749918963513791878657467
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            18936016538643448291185566774965691413741230050722305148133945573995337398774,
            9944542345511693887730318706269193995151231326821605911052788272902996800342
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            4392400993105242231729632178071268012455091428961089930317403440996678327464,
            18370836398687672334472391790693230405937204193864064671686739349152820172272
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            9172947223959772034978608784242881183242149550395725409360268737302891163052,
            3969316078393152725731635283306030983766388770125464694371180916907587580980
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            16751556250945756369353016492463535719191993326919364119043912574041563492234,
            13148854689565798067260934803495944529810709812627846283594724648432966096698
        );                                      
        
        vk.IC[28] = Pairing.G1Point( 
            19925295024786101249276900577859151988124475094037485794883369020566119672527,
            13482692168335742919248813646566995695670259917404136405769031616801126083814
        );                                      
        
        vk.IC[29] = Pairing.G1Point( 
            17725438153749164836022297894612407354186662689302668559749649934774478889464,
            11890293323433300040581555243692911179593282065823013959463544814454004276208
        );                                      
        
        vk.IC[30] = Pairing.G1Point( 
            192443426914245780225083835844780894422376512673193703078686908463769664308,
            9615401028002169291802382852421569359186139372489785180889504723839800485658
        );                                      
        
        vk.IC[31] = Pairing.G1Point( 
            12661130495434105727343452095062326888858175158858793633517683984911789835666,
            18528209105185188291046934622632753058677702523833467479465326307431284045945
        );                                      
        
        vk.IC[32] = Pairing.G1Point( 
            9267534234811960445311450352898968341381826122543029971963956904376773845212,
            10853522819670738347560947001057857341525858904600678137440275399295982902896
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
            uint[32] memory input
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
