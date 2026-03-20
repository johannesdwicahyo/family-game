import { useState, useEffect } from "react";

const S = { WARGA_WIN:3, WARGA_VOTE:1, IMP_WIN:5, IMP_SURV:2, JOKER_ELIM:8, MRW_GUESS:10, MRW_SURV:3 };

const WORD_PAIRS = [
  {n:"Kucing",i:"Anjing"},{n:"Singa",i:"Harimau"},{n:"Gajah",i:"Badak"},{n:"Kelinci",i:"Hamster"},
  {n:"Ikan",i:"Udang"},{n:"Burung",i:"Kelelawar"},{n:"Kuda",i:"Zebra"},{n:"Sapi",i:"Kerbau"},
  {n:"Kambing",i:"Domba"},{n:"Buaya",i:"Komodo"},{n:"Monyet",i:"Gorila"},{n:"Lumba-lumba",i:"Hiu"},
  {n:"Bebek",i:"Angsa"},{n:"Ayam",i:"Merpati"},{n:"Nasi",i:"Mie"},{n:"Rendang",i:"Gulai"},
  {n:"Soto",i:"Bakso"},{n:"Pizza",i:"Burger"},{n:"Sushi",i:"Ramen"},{n:"Gado-gado",i:"Pecel"},
  {n:"Sate",i:"Tongseng"},{n:"Nasi Goreng",i:"Mie Goreng"},{n:"Martabak",i:"Terang Bulan"},
  {n:"Pempek",i:"Siomay"},{n:"Rawon",i:"Konro"},{n:"Opor Ayam",i:"Kari Ayam"},
  {n:"Rujak",i:"Asinan"},{n:"Tempe",i:"Tahu"},{n:"Kerupuk",i:"Emping"},
  {n:"Lontong",i:"Ketupat"},{n:"Roti",i:"Kue"},{n:"Es Krim",i:"Pudding"},{n:"Donat",i:"Bolu"},
  {n:"Nasi Uduk",i:"Nasi Kuning"},{n:"Ayam Geprek",i:"Ayam Bakar"},{n:"Mie Ayam",i:"Mie Pangsit"},
  {n:"Kopi",i:"Teh"},{n:"Jus Jeruk",i:"Jus Mangga"},{n:"Es Teh",i:"Es Jeruk"},
  {n:"Susu",i:"Yogurt"},{n:"Air Mineral",i:"Soda"},{n:"Cincau",i:"Boba"},
  {n:"Es Campur",i:"Es Buah"},{n:"Wedang Jahe",i:"Wedang Uwuh"},
  {n:"Pantai",i:"Danau"},{n:"Gunung",i:"Bukit"},{n:"Pasar",i:"Mall"},
  {n:"Rumah Sakit",i:"Klinik"},{n:"Masjid",i:"Gereja"},{n:"Sekolah",i:"Universitas"},
  {n:"Bandara",i:"Pelabuhan"},{n:"Hotel",i:"Hostel"},{n:"Taman",i:"Kebun"},
  {n:"Hutan",i:"Perkebunan"},{n:"Museum",i:"Galeri"},{n:"Bioskop",i:"Teater"},
  {n:"Penjara",i:"Kantor Polisi"},{n:"Sawah",i:"Ladang"},{n:"Stadion",i:"Lapangan"},
  {n:"Warung",i:"Restoran"},{n:"Bank",i:"Koperasi"},{n:"Apotek",i:"Toko Obat"},
  {n:"Kebun Binatang",i:"Taman Safari"},{n:"Dokter",i:"Perawat"},{n:"Guru",i:"Dosen"},
  {n:"Polisi",i:"Tentara"},{n:"Pilot",i:"Pramugari"},{n:"Chef",i:"Tukang Masak"},
  {n:"Hakim",i:"Jaksa"},{n:"Arsitek",i:"Kontraktor"},{n:"Wartawan",i:"Penulis"},
  {n:"Aktor",i:"Penyanyi"},{n:"Petani",i:"Nelayan"},{n:"Programmer",i:"Designer"},
  {n:"Psikolog",i:"Psikiater"},{n:"Fotografer",i:"Videografer"},{n:"Pengacara",i:"Notaris"},
  {n:"Motor",i:"Sepeda"},{n:"Kereta",i:"Bus"},{n:"Pesawat",i:"Helikopter"},
  {n:"Kapal",i:"Perahu"},{n:"Taksi",i:"Angkot"},{n:"Bajaj",i:"Becak"},
  {n:"MRT",i:"LRT"},{n:"Kapal Selam",i:"Kapal Feri"},
  {n:"Sepak Bola",i:"Futsal"},{n:"Badminton",i:"Tenis"},{n:"Renang",i:"Selam"},
  {n:"Basket",i:"Voli"},{n:"Tinju",i:"Karate"},{n:"Lari",i:"Jalan Kaki"},
  {n:"Panjat Tebing",i:"Hiking"},{n:"Senam",i:"Yoga"},{n:"Tenis Meja",i:"Biliar"},
  {n:"Sepatu",i:"Sandal"},{n:"Baju",i:"Jaket"},{n:"Celana",i:"Rok"},
  {n:"Topi",i:"Helm"},{n:"Dompet",i:"Tas"},{n:"Kacamata",i:"Lensa Kontak"},
  {n:"Jam Tangan",i:"Gelang"},{n:"Batik",i:"Tenun"},{n:"Dasi",i:"Syal"},
  {n:"Bantal",i:"Guling"},{n:"Kasur",i:"Sofa"},{n:"Meja",i:"Kursi"},
  {n:"Lemari",i:"Rak"},{n:"Kompor",i:"Microwave"},{n:"Kulkas",i:"Freezer"},
  {n:"Televisi",i:"Monitor"},{n:"Kipas Angin",i:"AC"},{n:"Lampu",i:"Lilin"},
  {n:"Pintu",i:"Jendela"},{n:"Panci",i:"Wajan"},{n:"Gelas",i:"Cangkir"},
  {n:"Piring",i:"Mangkuk"},{n:"Sendok",i:"Garpu"},{n:"Blender",i:"Mixer"},
  {n:"Handphone",i:"Tablet"},{n:"Laptop",i:"Komputer"},{n:"Keyboard",i:"Mouse"},
  {n:"Printer",i:"Scanner"},{n:"Kamera",i:"Camcorder"},{n:"Headphone",i:"Earphone"},
  {n:"Charger",i:"Power Bank"},{n:"Speaker",i:"Soundbar"},{n:"Drone",i:"RC Mobil"},
  {n:"Hujan",i:"Badai"},{n:"Matahari",i:"Bulan"},{n:"Bintang",i:"Planet"},
  {n:"Angin",i:"Topan"},{n:"Gempa",i:"Tsunami"},{n:"Gunung Berapi",i:"Kawah"},
  {n:"Pelangi",i:"Awan"},{n:"Laut",i:"Samudra"},{n:"Banjir",i:"Longsor"},
  {n:"Wayang",i:"Boneka"},{n:"Gitar",i:"Ukulele"},{n:"Piano",i:"Keyboard"},
  {n:"Drum",i:"Gendang"},{n:"Film",i:"Serial"},{n:"Buku",i:"Komik"},
  {n:"Game",i:"Esport"},{n:"Konser",i:"Festival"},{n:"Karaoke",i:"Kafe Musik"},
  {n:"Gamelan",i:"Angklung"},{n:"Apel",i:"Pir"},{n:"Mangga",i:"Pepaya"},
  {n:"Pisang",i:"Nanas"},{n:"Durian",i:"Cempedak"},{n:"Jeruk",i:"Lemon"},
  {n:"Semangka",i:"Melon"},{n:"Anggur",i:"Kiwi"},{n:"Wortel",i:"Lobak"},
  {n:"Bayam",i:"Kangkung"},{n:"Tomat",i:"Cabai"},{n:"Bawang Merah",i:"Bawang Putih"},
  {n:"Kentang",i:"Singkong"},{n:"Jagung",i:"Kacang"},{n:"Rambutan",i:"Leci"},
  {n:"Alpukat",i:"Kelapa"},{n:"Pensil",i:"Pulpen"},{n:"Ujian",i:"Kuis"},
  {n:"Rapor",i:"Ijazah"},{n:"Spidol",i:"Kapur"},{n:"Obat",i:"Vitamin"},
  {n:"Suntik",i:"Infus"},{n:"Masker",i:"Sarung Tangan"},{n:"Plester",i:"Perban"},
  {n:"Kunci",i:"Gembok"},{n:"Payung",i:"Jas Hujan"},{n:"Sabun",i:"Sampo"},
  {n:"Cermin",i:"Foto"},{n:"Kalender",i:"Jam"},{n:"Gunting",i:"Pisau"},
  {n:"Tisu",i:"Serbet"},{n:"Koran",i:"Majalah"},{n:"ATM",i:"Mesin EDC"},
  {n:"Kartu Kredit",i:"Kartu Debit"},{n:"Istana",i:"Keraton"},{n:"Peta",i:"Kompas"},
  {n:"Robot",i:"Mesin"},{n:"Petasan",i:"Kembang Api"},{n:"Detektif",i:"Mata-mata"},
  {n:"Vampir",i:"Zombie"},{n:"Ninja",i:"Samurai"},{n:"Sulap",i:"Hipnotis"},
  {n:"Pernikahan",i:"Tunangan"},{n:"Piala",i:"Medali"},{n:"Password",i:"PIN"},
  {n:"Liburan",i:"Perjalanan Dinas"},{n:"Camping",i:"Glamping"},
  {n:"Sahur",i:"Buka Puasa"},{n:"Lebaran",i:"Natal"},{n:"Gosip",i:"Berita"},
];

const RI = {
  civilian:{label:"Warga",color:"#3cff6e",bg:"#003a0a",emoji:"👤",desc:"Dapat kata warga. Temukan impostornya!"},
  impostor:{label:"Impostor",color:"#ff3c3c",bg:"#3a0000",emoji:"🔪",desc:"Katamu berbeda! Coba tidak ketahuan."},
  joker:   {label:"Joker",   color:"#ffcc00",bg:"#2a2200",emoji:"🃏",desc:"Katamu sama warga. Goal: jadilah target eliminasi pertama!"},
  mr_white:{label:"Mr. White",color:"#a0a0ff",bg:"#0a0a2a",emoji:"❓",desc:"Tidak dapat kata. Kalau dieliminasi, tebak kata warga untuk menang besar!"},
};

const SI = {
  civilian:[{c:"Impostor ditemukan",p:"+3"},{c:"Vote benar ke impostor",p:"+1"}],
  impostor:[{c:"Lolos voting (menang)",p:"+5"},{c:"Per warga tersisa",p:"+2"}],
  joker:   [{c:"Dieliminasi pertama",p:"+8"},{c:"Tidak dieliminasi pertama",p:"+0"}],
  mr_white:[{c:"Tebak kata warga (benar)",p:"+10"},{c:"Lolos & warga kalah",p:"+3"}],
};

const MEDALS = ["🥇","🥈","🥉"];
const PH = {SETUP:"setup",REVEAL:"reveal",VOTE:"vote",JOKER_BANNER:"jb",GUESS:"guess",RESULT:"result",LB:"lb"};

function calcScores(players, votes, elimIdx, winner, jokerIdx) {
  return players.map((p,i) => {
    let pts=0; const bd=[];
    if (p.role==="civilian") {
      if (winner==="warga"){pts+=S.WARGA_WIN;bd.push({l:"Warga menang",p:S.WARGA_WIN});}
      const ii=players.findIndex(x=>x.role==="impostor");
      if (votes[i]===ii){pts+=S.WARGA_VOTE;bd.push({l:"Vote benar ke impostor",p:S.WARGA_VOTE});}
    }
    if (p.role==="impostor"&&winner==="impostor"){
      pts+=S.IMP_WIN;bd.push({l:"Impostor menang",p:S.IMP_WIN});
      const sv=players.filter((x,j)=>j!==elimIdx&&x.role==="civilian").length;
      if(sv>0){pts+=sv*S.IMP_SURV;bd.push({l:sv+" warga tersisa",p:sv*S.IMP_SURV});}
    }
    if (p.role==="joker"&&i===jokerIdx&&jokerIdx>=0){pts+=S.JOKER_ELIM;bd.push({l:"Dieliminasi pertama!",p:S.JOKER_ELIM});}
    if (p.role==="mr_white"){
      if(i===elimIdx&&winner==="mr_white"){pts+=S.MRW_GUESS;bd.push({l:"Tebak kata benar!",p:S.MRW_GUESS});}
      else if(i!==elimIdx&&winner!=="warga"){pts+=S.MRW_SURV;bd.push({l:"Lolos & warga kalah",p:S.MRW_SURV});}
    }
    return {name:p.name,role:p.role,pts,bd};
  });
}

export default function App() {
  const [phase,setPhase]=useState(PH.SETUP);
  const [rc,setRc]=useState({civilian:4,impostor:1,joker:0,mr_white:0});
  const [names,setNames]=useState(["Pemain 1","Pemain 2","Pemain 3","Pemain 4","Pemain 5"]);
  const [players,setPlayers]=useState([]);
  const [pair,setPair]=useState(null);
  const [revIdx,setRevIdx]=useState(0);
  const [showWord,setShowWord]=useState(false);
  const [votes,setVotes]=useState({});
  const [voterIdx,setVoterIdx]=useState(0);
  const [elimIdx,setElimIdx]=useState(null);
  const [jokerElimIdx,setJokerElimIdx]=useState(-1);
  const [guessVal,setGuessVal]=useState("");
  const [winner,setWinner]=useState(null);
  const [roundScores,setRoundScores]=useState([]);
  const [lb,setLb]=useState({});
  const [roundNum,setRoundNum]=useState(0);
  const [tab,setTab]=useState("roles");
  const [scoreTab,setScoreTab]=useState("round");
  const [expanded,setExpanded]=useState(null);

  const total=Object.values(rc).reduce((a,b)=>a+b,0);

  useEffect(()=>{
    const n=[...names];
    while(n.length<total) n.push("Pemain "+(n.length+1));
    setNames(n.slice(0,total));
  },[total]);

  const ri=(role)=>RI[role]||RI.civilian;

  const adjRole=(role,d)=>{
    const next=rc[role]+d;
    if(next<0||(role==="impostor"&&next<1)) return;
    setRc({...rc,[role]:next});
  };

  const startGame=()=>{
    const p=WORD_PAIRS[Math.floor(Math.random()*WORD_PAIRS.length)];
    const roles=[
      ...Array(rc.civilian).fill("civilian"),
      ...Array(rc.impostor).fill("impostor"),
      ...Array(rc.joker).fill("joker"),
      ...Array(rc.mr_white).fill("mr_white"),
    ].sort(()=>Math.random()-.5);
    const ps=names.map((name,idx)=>({
      name, role:roles[idx],
      word:roles[idx]==="civilian"||roles[idx]==="joker"?p.n:roles[idx]==="impostor"?p.i:null,
    }));
    setPair(p);setPlayers(ps);setRevIdx(0);setShowWord(false);
    setVotes({});setVoterIdx(0);setElimIdx(null);setJokerElimIdx(-1);
    setGuessVal("");setWinner(null);setRoundScores([]);setExpanded(null);
    setRoundNum(rn=>rn+1);setPhase(PH.REVEAL);
  };

  const activePlayers=players.filter((_,i)=>i!==jokerElimIdx);

  const doFinish=(win,eIdx,finalVotes,jIdx)=>{
    setWinner(win);
    const scores=calcScores(players,finalVotes,eIdx,win,jIdx);
    setRoundScores(scores);
    const newLb={...lb};
    scores.forEach(s=>{newLb[s.name]=(newLb[s.name]||0)+s.pts;});
    setLb(newLb);
    setPhase(PH.RESULT);
  };

  const submitVote=(origIdx)=>{
    const nv={...votes,[voterIdx]:origIdx};
    setVotes(nv);
    if(voterIdx+1<activePlayers.length){setVoterIdx(voterIdx+1);return;}
    const tally={};
    Object.values(nv).forEach(v=>{tally[v]=(tally[v]||0)+1;});
    const maxV=Math.max(...Object.values(tally));
    const topIdx=parseInt(Object.keys(tally).find(k=>tally[k]===maxV));
    const role=players[topIdx]?.role;
    setElimIdx(topIdx);
    if(role==="joker"){setJokerElimIdx(topIdx);setPhase(PH.JOKER_BANNER);}
    else if(role==="mr_white"){setPhase(PH.GUESS);}
    else if(role==="impostor"){doFinish("warga",topIdx,nv,jokerElimIdx);}
    else{doFinish("impostor",topIdx,nv,jokerElimIdx);}
  };

  const submitGuess=()=>{
    const correct=guessVal.trim().toLowerCase()===pair?.n?.toLowerCase();
    doFinish(correct?players[elimIdx]?.role:"warga",elimIdx,votes,jokerElimIdx);
  };

  const continueAfterJoker=()=>{setVotes({});setVoterIdx(0);setElimIdx(null);setPhase(PH.VOTE);};
  const resetAll=()=>{setLb({});setRoundNum(0);setPhase(PH.SETUP);};

  const lbEntries=Object.entries(lb).sort((a,b)=>b[1]-a[1]);
  const maxLb=lbEntries.length?lbEntries[0][1]:1;
  const WC={warga:"#3cff6e",impostor:"#ff3c3c",joker:"#ffcc00",mr_white:"#a0a0ff"};
  const WL={warga:"WARGA MENANG!",impostor:"IMPOSTOR MENANG!",joker:"JOKER MENANG!",mr_white:"MR. WHITE MENANG!"};
  const WE={warga:"🎉",impostor:"💀",joker:"🃏",mr_white:"❓"};

  const curPlayer=players[revIdx];
  const isSpecialRole=curPlayer&&(curPlayer.role==="joker"||curPlayer.role==="mr_white");

  return (
    <div style={{minHeight:"100vh",background:"#0a0a0f",color:"#f0ede8",fontFamily:"'Courier New',monospace",display:"flex",flexDirection:"column",alignItems:"center",padding:"24px 16px 56px"}}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Space+Mono:wght@400;700&display=swap');
        *{box-sizing:border-box;margin:0;padding:0}
        .T{font-family:'Bebas Neue',sans-serif;font-size:clamp(48px,10vw,88px);letter-spacing:8px;color:#ff3c3c;text-shadow:4px 4px 0 #7a0000,0 0 40px #ff3c3c88;line-height:1}
        .SUB{font-family:'Space Mono',monospace;font-size:11px;letter-spacing:4px;color:#666;text-transform:uppercase}
        .card{background:#12121a;border:1px solid #2a2a3a;border-radius:2px;padding:20px;width:100%;max-width:460px}
        .btn{background:#ff3c3c;color:#fff;border:none;padding:14px;font-family:'Bebas Neue',sans-serif;font-size:22px;letter-spacing:3px;cursor:pointer;width:100%;border-radius:2px;transition:all .15s}
        .btn:hover:not(:disabled){background:#ff5555;transform:translateY(-1px);box-shadow:0 4px 20px #ff3c3c55}
        .btn:disabled{opacity:.35;cursor:not-allowed}
        .ghost{background:transparent;color:#888;border:1px solid #2a2a3a;padding:10px;font-family:'Space Mono',monospace;font-size:12px;cursor:pointer;border-radius:2px;transition:all .15s;width:100%}
        .ghost:hover{border-color:#ff3c3c;color:#ff3c3c}
        .inp{background:#1a1a28;border:1px solid #2a2a3a;color:#f0ede8;padding:10px 14px;font-family:'Space Mono',monospace;font-size:14px;border-radius:2px;width:100%;outline:none}
        .inp:focus{border-color:#ff3c3c}
        .cbt{background:#1a1a28;border:1px solid #2a2a3a;color:#f0ede8;width:32px;height:32px;font-size:16px;cursor:pointer;border-radius:2px;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-family:monospace;transition:all .15s}
        .cbt:hover:not(:disabled){border-color:#ff3c3c;color:#ff3c3c}
        .cbt:disabled{opacity:.25;cursor:not-allowed}
        .WORD{font-family:'Bebas Neue',sans-serif;font-size:clamp(52px,14vw,96px);letter-spacing:6px;color:#f0ede8;text-align:center;line-height:1;padding:16px 0}
        .vbtn{background:#1a1a28;border:1px solid #2a2a3a;padding:10px 14px;border-radius:2px;cursor:pointer;transition:all .15s;display:flex;justify-content:space-between;align-items:center;width:100%}
        .vbtn:hover:not(:disabled){border-color:#ff3c3c;background:#1f1f2e}
        .vbtn.sel{border-color:#ff3c3c;background:#2a0000}
        .vbtn:disabled{cursor:not-allowed;opacity:.6}
        .tab{flex:1;background:transparent;border:1px solid #2a2a3a;color:#666;padding:10px;font-family:'Space Mono',monospace;font-size:11px;letter-spacing:2px;cursor:pointer;transition:all .15s;text-transform:uppercase}
        .tab.a{background:#1a1a28;border-color:#ff3c3c;color:#f0ede8}
        .dot{width:7px;height:7px;border-radius:50%;display:inline-block;margin:0 3px}
        .hr{border:none;border-top:1px solid #1e1e2e;margin:12px 0}
        .fi{animation:fi .35s ease}
        @keyframes fi{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
        .bl{animation:bl 1s step-end infinite}
        @keyframes bl{0%,100%{opacity:1}50%{opacity:0}}
        .vbw{height:3px;background:#1a1a28;border-radius:2px;margin-top:4px}
        .vb{height:3px;background:#ff3c3c;border-radius:2px;transition:width .4s}
        .rbig{font-family:'Bebas Neue',sans-serif;font-size:clamp(36px,9vw,68px);letter-spacing:5px;text-align:center;line-height:1.1}
        .sl{position:fixed;top:0;left:0;right:0;bottom:0;background:repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(0,0,0,.03) 2px,rgba(0,0,0,.03) 4px);pointer-events:none;z-index:0}
        .wrap{position:relative;z-index:1;width:100%;max-width:460px;display:flex;flex-direction:column;gap:16px}
        .srow{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:2px;cursor:pointer}
        .srow:hover{background:#1a1a28}
        .pts{font-family:'Bebas Neue',sans-serif;font-size:26px;letter-spacing:2px;min-width:56px;text-align:right;flex-shrink:0}
        .bkd{background:#0e0e18;border:1px solid #2a2a3a;border-radius:2px;padding:10px 12px;margin-top:4px}
        .lbw{height:6px;background:#1a1a28;border-radius:3px;margin-top:4px;overflow:hidden}
        .lbb{height:6px;border-radius:3px;transition:width .8s cubic-bezier(.4,0,.2,1)}
        .rr{display:flex;justify-content:space-between;align-items:center;padding:5px 0;border-bottom:1px solid #1a1a28;font-size:11px}
      `}</style>
      <div className="sl" />
      <div className="wrap">

        {/* HEADER */}
        <div style={{textAlign:"center"}}>
          <div className="T">IMPOSTOR</div>
          <div style={{display:"flex",justifyContent:"center",alignItems:"center",gap:12,marginTop:4}}>
            <div className="SUB">permainan kata keluarga</div>
            {roundNum>0&&<div onClick={()=>setPhase(PH.LB)} style={{cursor:"pointer",background:"#1a1a28",border:"1px solid #2a2a3a",borderRadius:2,padding:"3px 10px",fontSize:10,letterSpacing:2,color:"#ffcc00",fontFamily:"'Space Mono',monospace"}}>LB</div>}
          </div>
        </div>

        {/* SETUP */}
        {phase===PH.SETUP&&(
          <div className="card fi">
            <div style={{display:"flex",marginBottom:20}}>
              {[["roles","Peran"],["names","Nama"],["rules","Skor"]].map(([k,l])=>(
                <button key={k} className={"tab"+(tab===k?" a":"")} onClick={()=>setTab(k)}>{l}</button>
              ))}
            </div>
            {tab==="roles"&&(
              <div>
                <div className="SUB" style={{marginBottom:16}}>total pemain: <span style={{color:"#f0ede8"}}>{total}</span></div>
                {[["civilian",0],["impostor",1],["joker",0],["mr_white",0]].map(([key,min])=>{
                  const info=ri(key);
                  return (
                    <div key={key} style={{display:"flex",alignItems:"center",gap:10,padding:"10px 0",borderBottom:"1px solid #1a1a28"}}>
                      <span style={{fontSize:24,width:32,textAlign:"center"}}>{info.emoji}</span>
                      <div style={{flex:1,minWidth:0}}>
                        <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:20,letterSpacing:3,color:info.color}}>{info.label}</div>
                        <div style={{fontSize:10,color:"#555",lineHeight:1.4}}>{info.desc}</div>
                      </div>
                      <div style={{display:"flex",alignItems:"center",gap:8,flexShrink:0}}>
                        <button className="cbt" onClick={()=>adjRole(key,-1)} disabled={rc[key]<=min}>-</button>
                        <span style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:28,minWidth:26,textAlign:"center",color:info.color}}>{rc[key]}</span>
                        <button className="cbt" onClick={()=>adjRole(key,1)}>+</button>
                      </div>
                    </div>
                  );
                })}
                {total<3&&<div style={{color:"#ff3c3c",fontSize:11,marginTop:10}}>Minimal 3 pemain</div>}
              </div>
            )}
            {tab==="names"&&(
              <div>
                <div className="SUB" style={{marginBottom:14}}>nama pemain ({total} orang)</div>
                <div style={{display:"flex",flexDirection:"column",gap:8}}>
                  {names.map((n,i)=>(
                    <input key={i} className="inp" value={n}
                      onChange={e=>{const u=[...names];u[i]=e.target.value;setNames(u);}}
                      placeholder={"Pemain "+(i+1)}
                    />
                  ))}
                </div>
              </div>
            )}
            {tab==="rules"&&(
              <div>
                <div className="SUB" style={{marginBottom:14}}>sistem penilaian</div>
                {[["civilian","👤"],["impostor","🔪"],["joker","🃏"],["mr_white","❓"]].map(([role,emoji])=>(
                  <div key={role} style={{marginBottom:14}}>
                    <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:18,color:ri(role).color,letterSpacing:3,marginBottom:6}}>{emoji} {ri(role).label}</div>
                    {SI[role].map((r,i)=>(
                      <div key={i} className="rr">
                        <span style={{color:"#888"}}>{r.c}</span>
                        <span style={{color:ri(role).color,fontFamily:"'Bebas Neue',sans-serif",fontSize:18,letterSpacing:2}}>{r.p}</span>
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            )}
            <div style={{marginTop:20,display:"flex",flexDirection:"column",gap:8}}>
              <button className="btn" disabled={total<3} onClick={startGame}>MULAI GAME</button>
              {roundNum>0&&<button className="ghost" onClick={resetAll}>RESET LEADERBOARD</button>}
            </div>
          </div>
        )}

        {/* REVEAL */}
        {phase===PH.REVEAL&&curPlayer&&(
          <div className="card fi" style={{textAlign:"center"}}>
            <div className="SUB" style={{marginBottom:6}}>giliran melihat kata</div>
            <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:34,letterSpacing:4,marginBottom:16}}>{curPlayer.name}</div>
            <div style={{marginBottom:20}}>
              {players.map((_,i)=>(
                <span key={i} className="dot" style={{background:i<revIdx?"#3cff6e":i===revIdx?"#ff3c3c":"#2a2a3a"}} />
              ))}
            </div>
            {!showWord?(
              <button className="btn" onClick={()=>setShowWord(true)}>LIHAT KATAKU</button>
            ):(
              <div>
                {isSpecialRole&&(
                  <div style={{marginBottom:12}}>
                    <div style={{display:"inline-flex",alignItems:"center",gap:8,background:ri(curPlayer.role).bg,border:"1px solid "+ri(curPlayer.role).color+"44",borderRadius:2,padding:"8px 16px",marginBottom:8}}>
                      <span style={{fontSize:22}}>{ri(curPlayer.role).emoji}</span>
                      <span style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:22,letterSpacing:3,color:ri(curPlayer.role).color}}>{ri(curPlayer.role).label}</span>
                    </div>
                    <div style={{background:"#1a1a28",border:"1px solid #2a2a3a",borderRadius:2,padding:"8px 12px",marginBottom:8,fontSize:11,color:"#666",textAlign:"left"}}>
                      {ri(curPlayer.role).desc}
                    </div>
                  </div>
                )}
                {curPlayer.word
                  ?<div>
                    <div className="WORD">{curPlayer.word}</div>
                    <div style={{fontSize:10,color:"#555",letterSpacing:2,marginBottom:16}}>JANGAN TUNJUKKAN KE SIAPAPUN</div>
                  </div>
                  :<div style={{fontSize:13,color:"#a0a0ff",margin:"16px 0",lineHeight:1.7}}>Kamu tidak mendapat kata.<br/>Ikuti diskusi dan tebak!</div>
                }
                <button className="btn" onClick={()=>{
                  setShowWord(false);
                  if(revIdx+1<players.length) setRevIdx(revIdx+1);
                  else setPhase(PH.VOTE);
                }}>
                  {revIdx+1<players.length?"PEMAIN BERIKUTNYA":"MULAI DISKUSI"}
                </button>
              </div>
            )}
          </div>
        )}

        {/* VOTE */}
        {phase===PH.VOTE&&activePlayers.length>0&&(
          <div className="card fi">
            {jokerElimIdx>=0&&(
              <div style={{background:"#2a2200",border:"1px solid #ffcc0033",borderRadius:2,padding:"6px 12px",marginBottom:12,fontSize:11,color:"#ffcc00",textAlign:"center"}}>
                Joker sudah keluar — game berlanjut!
              </div>
            )}
            <div style={{textAlign:"center",marginBottom:16}}>
              <div className="SUB" style={{marginBottom:6}}>giliran voting</div>
              <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:30,letterSpacing:4,color:"#ff3c3c"}}>{activePlayers[voterIdx]?.name}</div>
              <div className="SUB">pilih siapa yang paling mencurigakan</div>
            </div>
            <div style={{display:"flex",flexDirection:"column",gap:8}}>
              {activePlayers.map((p,ai)=>{
                if(ai===voterIdx) return null;
                const origIdx=players.findIndex(pl=>pl.name===p.name);
                const count=Object.values(votes).filter(v=>v===origIdx).length;
                const myVote=votes[voterIdx]===origIdx;
                return (
                  <div key={p.name}>
                    <button className={"vbtn"+(myVote?" sel":"")}
                      onClick={()=>{if(votes[voterIdx]===undefined) submitVote(origIdx);}}
                      disabled={votes[voterIdx]!==undefined}>
                      <span style={{fontFamily:"'Space Mono',monospace",fontSize:13}}>{p.name}</span>
                      {count>0&&<span style={{background:"#3a0000",color:"#ff3c3c",border:"1px solid #ff3c3c44",fontSize:10,letterSpacing:2,padding:"2px 8px",borderRadius:2}}>{count}x</span>}
                    </button>
                    {count>0&&<div className="vbw"><div className="vb" style={{width:(count/Object.keys(votes).length*100)+"%"}}/></div>}
                  </div>
                );
              })}
            </div>
            <div className="hr"/>
            <div className="SUB" style={{textAlign:"center"}}>{Object.keys(votes).length} / {activePlayers.length} sudah voting</div>
          </div>
        )}

        {/* JOKER BANNER */}
        {phase===PH.JOKER_BANNER&&jokerElimIdx>=0&&(
          <div className="card fi" style={{textAlign:"center"}}>
            <div style={{fontSize:56,marginBottom:8}}>🃏</div>
            <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:40,letterSpacing:6,color:"#ffcc00",marginBottom:6}}>JOKER MENANG!</div>
            <div style={{fontFamily:"'Space Mono',monospace",fontSize:14,color:"#ffcc00",marginBottom:8}}>{players[jokerElimIdx]?.name}</div>
            <div style={{fontSize:12,color:"#888",marginBottom:8,lineHeight:1.7}}>Berhasil dieliminasi pertama dan meraih</div>
            <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:48,color:"#ffcc00",letterSpacing:4,marginBottom:16}}>+{S.JOKER_ELIM} POIN</div>
            <div style={{background:"#2a2200",border:"1px solid #ffcc0033",borderRadius:2,padding:"10px 14px",marginBottom:20,fontSize:12,color:"#aaa",lineHeight:1.6}}>
              Game tetap berlanjut!<br/>Pemain lain masih harus menemukan Impostor.
            </div>
            <button className="btn" style={{background:"#b38a00"}} onClick={continueAfterJoker}>LANJUTKAN GAME</button>
          </div>
        )}

        {/* MR WHITE GUESS */}
        {phase===PH.GUESS&&elimIdx!==null&&(
          <div className="card fi" style={{textAlign:"center"}}>
            <div style={{fontSize:40,marginBottom:8}}>❓</div>
            <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:28,letterSpacing:4,color:"#a0a0ff",marginBottom:6}}>MR. WHITE DIELIMINASI!</div>
            <div style={{fontSize:12,color:"#888",marginBottom:4,lineHeight:1.7}}>
              <b style={{color:"#a0a0ff"}}>{players[elimIdx]?.name}</b> adalah Mr. White.<br/>Tebak kata warga untuk menang!
            </div>
            <div style={{background:"#0a0a2a",border:"1px solid #a0a0ff44",borderRadius:2,padding:"6px 12px",margin:"12px 0",fontSize:11,color:"#a0a0ff"}}>
              Tebak benar = +{S.MRW_GUESS} poin besar!
            </div>
            <input className="inp" value={guessVal} onChange={e=>setGuessVal(e.target.value)}
              placeholder="Tebak kata warga..."
              style={{marginBottom:12,textAlign:"center",fontSize:16}}
              onKeyDown={e=>{if(e.key==="Enter"&&guessVal.trim()) submitGuess();}}
            />
            <button className="btn" disabled={!guessVal.trim()} onClick={submitGuess}>TEBAK SEKARANG</button>
          </div>
        )}

        {/* RESULT */}
        {phase===PH.RESULT&&winner&&(
          <div className="card fi">
            <div style={{textAlign:"center",marginBottom:16}}>
              <div style={{fontSize:40,marginBottom:4}}>{WE[winner]}</div>
              <div className="rbig" style={{color:WC[winner]}}>{WL[winner]}</div>
              {jokerElimIdx>=0&&winner!=="joker"&&(
                <div style={{fontSize:11,color:"#ffcc00",marginTop:6}}>
                  🃏 {players[jokerElimIdx]?.name} (Joker) juga menang ronde ini!
                </div>
              )}
            </div>
            <div style={{display:"flex",marginBottom:16}}>
              <button className={"tab"+(scoreTab==="round"?" a":"")} onClick={()=>setScoreTab("round")}>Skor Ronde</button>
              <button className={"tab"+(scoreTab==="lb"?" a":"")} onClick={()=>setScoreTab("lb")}>Leaderboard</button>
            </div>
            {scoreTab==="round"&&(
              <div>
                {[...roundScores].sort((a,b)=>b.pts-a.pts).map((s,rank)=>{
                  const info=ri(s.role);const isExp=expanded===s.name;
                  return (
                    <div key={s.name} style={{marginBottom:8}}>
                      <div className="srow" style={{background:rank===0?"#1a1a10":"#0e0e18",border:"1px solid "+(rank===0?"#ffcc0033":"#2a2a3a")}}
                        onClick={()=>setExpanded(isExp?null:s.name)}>
                        <div style={{fontSize:18,width:28,textAlign:"center"}}>{rank<3?MEDALS[rank]:info.emoji}</div>
                        <div style={{flex:1}}>
                          <div style={{fontFamily:"'Space Mono',monospace",fontSize:13,color:rank===0?"#ffcc00":"#f0ede8"}}>{s.name}</div>
                          <div style={{fontSize:10,color:info.color,letterSpacing:2}}>{info.label}</div>
                        </div>
                        <div style={{display:"flex",alignItems:"center",gap:8}}>
                          <div className="pts" style={{color:s.pts>0?(rank===0?"#ffcc00":info.color):"#555"}}>{s.pts>0?"+"+s.pts:s.pts}</div>
                          <div style={{color:"#555",fontSize:12}}>{isExp?"▲":"▼"}</div>
                        </div>
                      </div>
                      {isExp&&(
                        <div className="bkd fi">
                          {s.bd.length===0
                            ?<div style={{color:"#555",fontSize:11,padding:"6px 0"}}>Tidak ada poin ronde ini.</div>
                            :s.bd.map((b,bi)=>(
                              <div key={bi} style={{display:"flex",justifyContent:"space-between",padding:"4px 0",borderBottom:"1px solid #1a1a28",fontSize:11}}>
                                <span style={{color:"#888"}}>{b.l}</span>
                                <span style={{color:info.color,fontFamily:"'Bebas Neue',sans-serif",fontSize:16}}>+{b.p}</span>
                              </div>
                            ))
                          }
                        </div>
                      )}
                    </div>
                  );
                })}
                <div style={{fontSize:10,color:"#444",textAlign:"center",marginTop:8}}>tap nama untuk detail poin</div>
              </div>
            )}
            {scoreTab==="lb"&&(
              <div>
                <div className="SUB" style={{marginBottom:12}}>total setelah {roundNum} ronde</div>
                {lbEntries.map(([name,pts],rank)=>{
                  const w=maxLb>0?Math.max(4,(pts/maxLb)*100):0;
                  return (
                    <div key={name} style={{marginBottom:10}}>
                      <div style={{display:"flex",alignItems:"center",gap:10}}>
                        <div style={{fontSize:18,width:28}}>{rank<3?MEDALS[rank]:"#"+(rank+1)}</div>
                        <div style={{flex:1,fontFamily:"'Space Mono',monospace",fontSize:13,color:rank===0?"#ffcc00":"#f0ede8"}}>{name}</div>
                        <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:26,color:rank===0?"#ffcc00":"#f0ede8",letterSpacing:2}}>{pts}</div>
                      </div>
                      <div className="lbw"><div className="lbb" style={{width:w+"%",background:rank===0?"#ffcc00":rank===1?"#aaa":rank===2?"#cd7f32":"#3a3a5a"}}/></div>
                    </div>
                  );
                })}
              </div>
            )}
            <div style={{background:"#1a1a28",border:"1px solid #2a2a3a",borderRadius:2,padding:"8px 14px",margin:"16px 0",fontSize:12}}>
              <div style={{color:"#555",marginBottom:3,letterSpacing:2,fontSize:10}}>PASANGAN KATA</div>
              <span style={{color:"#3cff6e"}}>Warga: {pair?.n}</span>
              <span style={{color:"#555",margin:"0 10px"}}>vs</span>
              <span style={{color:"#ff3c3c"}}>Impostor: {pair?.i}</span>
            </div>
            <div style={{display:"flex",flexDirection:"column",gap:8}}>
              <button className="btn" onClick={startGame}>MAIN LAGI</button>
              <button className="ghost" onClick={()=>setPhase(PH.SETUP)}>GANTI PEMAIN / PERAN</button>
            </div>
          </div>
        )}

        {/* LEADERBOARD */}
        {phase===PH.LB&&(
          <div className="card fi">
            <div style={{textAlign:"center",marginBottom:20}}>
              <div style={{fontSize:40,marginBottom:4}}>🏆</div>
              <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:42,letterSpacing:6,color:"#ffcc00"}}>LEADERBOARD</div>
              <div className="SUB">{roundNum} ronde dimainkan</div>
            </div>
            {lbEntries.length===0
              ?<div style={{textAlign:"center",color:"#555",fontSize:12,padding:"20px 0"}}>Belum ada data</div>
              :lbEntries.map(([name,pts],rank)=>{
                const w=maxLb>0?Math.max(4,(pts/maxLb)*100):0;
                return (
                  <div key={name} style={{marginBottom:14}}>
                    <div style={{display:"flex",alignItems:"center",gap:12}}>
                      <div style={{fontSize:24,width:36,textAlign:"center"}}>{rank<3?MEDALS[rank]:<span style={{fontFamily:"'Space Mono',monospace",fontSize:13,color:"#555"}}>{"#"+(rank+1)}</span>}</div>
                      <div style={{flex:1,fontFamily:"'Space Mono',monospace",fontSize:14,color:rank===0?"#ffcc00":"#f0ede8"}}>{name}</div>
                      <div style={{fontFamily:"'Bebas Neue',sans-serif",fontSize:34,letterSpacing:2,color:rank===0?"#ffcc00":rank===1?"#ccc":rank===2?"#cd7f32":"#888"}}>{pts}</div>
                    </div>
                    <div style={{marginLeft:48}}>
                      <div className="lbw"><div className="lbb" style={{width:w+"%",background:rank===0?"linear-gradient(90deg,#ffcc00,#ff9900)":rank===1?"#aaa":rank===2?"#cd7f32":"#3a3a5a"}}/></div>
                    </div>
                  </div>
                );
              })
            }
            <div className="hr"/>
            <div style={{display:"flex",flexDirection:"column",gap:8,marginTop:4}}>
              <button className="btn" onClick={startGame}>MAIN RONDE BARU</button>
              <button className="ghost" onClick={()=>setPhase(PH.SETUP)}>PENGATURAN</button>
              <button className="ghost" style={{color:"#ff3c3c55",borderColor:"#ff3c3c22"}} onClick={resetAll}>RESET SEMUA SKOR</button>
            </div>
          </div>
        )}

        <div style={{textAlign:"center",paddingBottom:8}}>
          <div className="SUB bl">SELAMAT BERMAIN</div>
        </div>
      </div>
    </div>
  );
}
