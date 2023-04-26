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
        vk.IC = new Pairing.G1Point[](28);
        
        vk.IC[0] = Pairing.G1Point( 
            1163739453057472902075374226124544553682734013976368493779610390067435770145,
            20641796040949190857488224940078192363449087504047178574799928261566992355421
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            7224795356619094753177448304821088954701368559805012426252946806247608784865,
            16902283980828859496342996843631404280373500642581813556036942176754536675580
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            11172682006143722117167080456571063511118538718540287125950539404634813492478,
            4360773071835677124801551445218849671796415624734781748997926605198842781315
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            11842343581417479876984445861890906940785867999869051043088810258008964914561,
            16331969636385828036398578063951341412475768041178464453163196673983519527602
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            262443421391140407677453994725820547150263324345493934730463918165178092833,
            8759180325270417101581921474741668215986933906313756459154991579068971573702
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            11703286180339730397924253308774730004404677017296337864244745038400399857844,
            19407572258765130965296612850721403520679678907392353299601118264188704270804
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            14756031577485682930755084058910080470933256771831737260292767416909315770371,
            4153509071704429076204814474690344022942849071601875436125703725901152738894
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            20518559273565882160549635848475064476519958890072720885380432118903577601977,
            13410099153511933473599947715047616623764248534532385409816646219769129571925
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            8409638567317300204652727033709621667824419510571452760859436995712433597713,
            11313205432654484485150579245406386229264088157647013092201319709698860549810
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            17547593362368604424611657018071751903174904130343931116611059284079567095990,
            3868760039625639281315957164399336900934039443998372531781514695751756989888
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            20911186217223454243073140917274811320407350881602770322927820821174583676688,
            11177615634436527984574617421216850139591729777173334409978480355727242497379
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            14794872368080415178604743654957590657821346014846359216180961108201689396495,
            1354195024934603664250891526877446882246092629843279254470043930379675702449
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            12542240077864247653093030369926850004324999924769467540530861146201511219778,
            428300230095784582144289707267045877687896060931413307132569480421375612242
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            593456027599113581240775726724985852160978349577187364693114729790078712035,
            12796542136186349896210222210041601024109390429826913525785641689955307044165
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            4795182974813525187599716925043150863106708249931986803719725239824066551835,
            12094953764953564409741661486071972838306059195104970233319062177772414787615
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            14976944318488895405595877891963714646335609763731539423537031289711031539350,
            19963113134729487098692362426371915011418174403149711721841938929257783963771
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            6484515100559439635900577893216926672510937263566935578284051719378669722139,
            9960374918620612465567234289064461632821218239566061609202080724476229722500
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            16767352945382336036901868251366440813969562012821284228014704265676705748692,
            15183319770393752140670598242474444394497849125860673761900406818019005759674
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            20406788637430408828316492528094202137674866829973103098204886129976662252454,
            16733755400296708459735512086131318635909295114114391979299948619364170445977
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            2765742612954876982341021721354271932839250678064474110990960471604268925970,
            18495629743218429873669292932691133866059600778324632172393676984926016558786
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            2315702115760590662528482715037553467828452419982410843553336036231540709393,
            10887864194154175008095387212198647629834370100336122042865493021175688066775
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            16672477834277599153023191180799204074378171145833403260326099866099873180260,
            13565878108008778540947751981905152873685267885163373422564201704942888331781
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            4388338938289867528237857184965196902258263118035647084301550212383630366197,
            1122956322615074157640184598445327710185242838702585613797852830751225944233
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            1170917177337549775285217944095475308876903911563246268272267969893187449942,
            14625450331921597592086685644227451991456836485051240125301541884146332331050
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            4150572503590700379308006269087737083007869909430186124010443470812496297281,
            7585362860586821540276149881998283997006486131814972834499564216764271026052
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            7293634855943322205889397847738457521813686003672270708993489345354649273376,
            10045004669914545628988248025046454108001956227737633871528450965000692189103
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            871299922858022016402749114624462910634952857389600969703519075236758878735,
            16274488755564013022563172139111912709491652779084993559779848382630370417778
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            1395841187198223907661938669998829707790946352565019675564122835148691335377,
            19560334118116291273195915422546017684926648971457668171283866229519844890239
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
            uint[27] memory input
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
