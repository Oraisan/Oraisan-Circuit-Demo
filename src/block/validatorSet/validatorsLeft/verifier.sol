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
            15555391783802208774784523529457947058711112564696104464628564330284168643963,
            15286983013353950398470327491416262103494526922224415757432604333245890501830
        );                                      
        
        vk.IC[1] = Pairing.G1Point( 
            21354562434465738054797348317251625836019513153129553877429565633832174222187,
            19425529785495525637411355708395822452484038216877480554039412095574884901585
        );                                      
        
        vk.IC[2] = Pairing.G1Point( 
            9728097221758356646806519736479012530096789289879484640801983057811951744647,
            21051128743428195969785566904977055217218105953255890719172164356566441434604
        );                                      
        
        vk.IC[3] = Pairing.G1Point( 
            8459582146627349433819446542367249971347069063381569047591254974901148587796,
            4265514244380360704883522486004329439972156837339034542719854281218696863433
        );                                      
        
        vk.IC[4] = Pairing.G1Point( 
            19401640150077916931220179161522912278798452039544853607674524373944202072527,
            9084668650213464691753782872871820378150768790566397356030534422470884849472
        );                                      
        
        vk.IC[5] = Pairing.G1Point( 
            19635192739580873860503309478291568918502382707921489257047263743785497546852,
            12432604330971584866372565715868243770524593639701071795524795253787802736979
        );                                      
        
        vk.IC[6] = Pairing.G1Point( 
            1205981836336805357515312461357205614634622566152462745077558552037548994867,
            8550396631642473334593978018647336634454472310246598049836015127257803551281
        );                                      
        
        vk.IC[7] = Pairing.G1Point( 
            17084439517879093866994818282809886993419569839702873311128873818782859471873,
            16842783913061228647366418975174654662228068080421169758688018993233527575348
        );                                      
        
        vk.IC[8] = Pairing.G1Point( 
            21457308865405224115203113694329728417375315471260753326555079392987201673186,
            10967084859004877887950687884299933445637665560177745019530558323699040215775
        );                                      
        
        vk.IC[9] = Pairing.G1Point( 
            20957240734709963913471511857732727985973838128293797506624288005476703073435,
            10265971081308158517002326698429913535643545888910852397514645361926706882857
        );                                      
        
        vk.IC[10] = Pairing.G1Point( 
            19902407925767564083448003248490282424675032855823310643416458930234427546366,
            17945679157494142522775044065157972088612230869268310112753834308868037108453
        );                                      
        
        vk.IC[11] = Pairing.G1Point( 
            13639794155442159588173141431148046467681091284027161022522595074082263138915,
            17842509833720959230485273570907197079716906075674903691625713125175204541843
        );                                      
        
        vk.IC[12] = Pairing.G1Point( 
            6977121908553603723829448171533374173698371566244518860786618564211120720088,
            8859141012454188158766544102775682362394306969902106601129749867775474607285
        );                                      
        
        vk.IC[13] = Pairing.G1Point( 
            18176010333391872833819547468714691268030889378196132147360841406176502553179,
            4089349081328312397279795448761263103620551094535389757481989687506629576135
        );                                      
        
        vk.IC[14] = Pairing.G1Point( 
            8428097233732827907542036279931656314457981668880836759798063287757833108860,
            2021366216506720579248053401355001686935428783129625856104120633615676062507
        );                                      
        
        vk.IC[15] = Pairing.G1Point( 
            19894202523571735228761189388252871653512831422463856876504109606470521353229,
            18041766037639462143492033210684091210817066575780575895523644332545230215550
        );                                      
        
        vk.IC[16] = Pairing.G1Point( 
            6384548449735131645096806108468879329740593570434676518167341638963085737987,
            2843041782500608526465643248623552986247771346141685951343937909921523271225
        );                                      
        
        vk.IC[17] = Pairing.G1Point( 
            16359961552397236916325062267312641585713791304144526897931556426894632901442,
            21423302122062013564122287348011171308659639950142078010414143614865399004043
        );                                      
        
        vk.IC[18] = Pairing.G1Point( 
            3055925104911820039341185340732670469940748799765878425761235577908756941148,
            303146002063653266121335675398145481585253543778644029359434003854933201616
        );                                      
        
        vk.IC[19] = Pairing.G1Point( 
            18597354150289350681799901063018012924213857352553234831709264465206183383823,
            7756231012693053569293525586398260263585299141077669418569903204760523752405
        );                                      
        
        vk.IC[20] = Pairing.G1Point( 
            10898205604870352628343642360472070814761261155284635165403414161219024974286,
            1157611602720596622638958614663943967892144682884213957767655134093337898215
        );                                      
        
        vk.IC[21] = Pairing.G1Point( 
            1218255771257727930271032685697607807593048349828032658824728572063947021111,
            17102151366727689589467658395102672308027583849736201395464778894095313600332
        );                                      
        
        vk.IC[22] = Pairing.G1Point( 
            18342947665635912405017778971852700990481264910572523098410012849211695906080,
            10592006015858453188248722351422308515979741421319658850347998810847442868103
        );                                      
        
        vk.IC[23] = Pairing.G1Point( 
            631665270665278765464845718902216631531378588819271636844935573855885428332,
            1766899530751325613502674713208351296105612184106441124544993548243266884182
        );                                      
        
        vk.IC[24] = Pairing.G1Point( 
            19603222846426563618719549962868333770593810248438984020427476527308307199262,
            11982323123679944113271841042835625084768007582559633543242052657469891722950
        );                                      
        
        vk.IC[25] = Pairing.G1Point( 
            13402245351162857857832705593663074398603926285471269791523697170083471291610,
            6017578673674658639620724602766509741028460646177066582178887171585342225913
        );                                      
        
        vk.IC[26] = Pairing.G1Point( 
            16380726089584291709847007083857897478274742116018028402542601706806538180128,
            3497586539845284209252315480761496183828995073674774570638674195985693506346
        );                                      
        
        vk.IC[27] = Pairing.G1Point( 
            12325611258705853524931357570839519955552209690569270828620968662643754512033,
            1355239686823517381822238896821165631680510993231505382309494448674754883738
        );                                      
        
        vk.IC[28] = Pairing.G1Point( 
            8931234867833428862625214600336459618389176396183476239775170262155016443846,
            19523821415931624969266708029243573195717598056400081306912164791998030722143
        );                                      
        
        vk.IC[29] = Pairing.G1Point( 
            8011420397522733673894849087568828902064499040805901166575201984155587545885,
            13508794676432973071461506619786171204534826657061037482497414082244971695883
        );                                      
        
        vk.IC[30] = Pairing.G1Point( 
            4439942446333018464305931292063424318385884086514117890442908383916890099594,
            17527009008383886087324789160236048373915961233723795812278906513138375009996
        );                                      
        
        vk.IC[31] = Pairing.G1Point( 
            4029754872171888202494033984006322055647107479330458135008985962388987062512,
            10927739148273665199695237652637637941877296795081786612942477510250185863445
        );                                      
        
        vk.IC[32] = Pairing.G1Point( 
            10598493418981399018928817748233845637916738884066999251217709181248622994032,
            20369749855659381096504600942941505084034110917162190777182041259577900750797
        );                                      
        
        vk.IC[33] = Pairing.G1Point( 
            1861245731338408373904173776535991711636410125256463204914765834796930060655,
            13431477833651714174125545818476139179033361534302275995023734393715838136661
        );                                      
        
        vk.IC[34] = Pairing.G1Point( 
            202758053448985422831376677830023746836432013374783834959117963632015454928,
            13590869874836976876219040786847967438529041445505406599754965410397618260142
        );                                      
        
        vk.IC[35] = Pairing.G1Point( 
            14408405717324682919110716164714022995057910961015461731120843800177454932379,
            13815980614217306081794760534796062928512212730311160464156903279773434042128
        );                                      
        
        vk.IC[36] = Pairing.G1Point( 
            520015249231680144356367828119210208248441212267549075345807473798035064443,
            5531892649860588110333622762646563778368545975604768633736053017138216099505
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
