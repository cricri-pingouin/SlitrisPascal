Program SLITRIS_Version_1_0;

Uses crt,dos,graph;

Type  FICHES = RECORD
                 Nom    : STRING[16];
                 Sco    : LongInt;
                 Lign   : Word;
                 Option : Word;
               END;
      Tab_Piece = array [1..4,1..4]   of boolean;

Var   Font                   : File;
      Fichier                : File of fiches;
      Fiche                  : array [1..10] of fiches;
      Plateau                : array [1..12,1..22] of boolean;
      GY                     : array [1..7] of integer;
      piece                  : Tab_Piece;
      posX,posY,i,a,b        : byte;
      num_piece,num_prochain : byte;
      niveau,hauteur,vitesse : byte;
      touche                 : char;
      perdu,ok,prochain,son  : boolean;
      size,lignes            : word;
      score                  : longint;
      bloc,fond,noir,goutte  : pointer;
      Fleche,FontS,FontT     : pointer;
      Chaine                 : string[6];
      Name                   : String[16];
      Cheat                  : boolean;

Const pieces : array [1..8] of Tab_piece
{ ม } = ( ( (false,true,false,false) ,(true,true,true,false)   ,(false,false,false,false),(false,false,false,false) ) ,
{ S }     ( (false,true,true,false)  ,(true,true,false,false)  ,(false,false,false,false),(false,false,false,false) ) ,
{ Z }     ( (true,true,false,false)  ,(false,true,true,false)  ,(false,false,false,false),(false,false,false,false) ) ,
{ ฺ }     ( (true,true,true,false)   ,(true,false,false,false) ,(false,false,false,false),(false,false,false,false) ) ,
{ ฟ }     ( (true,true,true,false)   ,(false,false,true,false) ,(false,false,false,false),(false,false,false,false) ) ,
{ ฤ }     ( (false,false,false,false),(true,true,true,true)    ,(false,false,false,false),(false,false,false,false) ) ,
{ÿþ }     ( (true,true,false,false)  ,(true,true,false,false)  ,(false,false,false,false),(false,false,false,false) ) ,
{ vide }  ( (false,false,false,false),(false,false,false,false),(false,false,false,false),(false,false,false,false) ) );

      GX : array [1..7] of integer
           = (190,240,350,420,470,501,590);


Procedure INIT_GRAPH;
var driver,mode,err : Integer;
begin
{ Initialisation systme graphique }
 Clrscr;
 DetectGraph(Driver,Mode);
 if (Driver<>VGA) or (Mode<>VGAHi) then
 begin
   Writeln(' This program needs a VGA display');
   Writeln(' in 640x480 mode, 16 colors.');
   halt(1);
 end;
 InitGraph(Driver,Mode,' '); { Mettre ici le chemin des BGI }
 Err := GraphResult;
 if not Err = grOk then
   begin
     Writeln('Error during graphics initialisation : ');
     Writeln(GraphErrorMsg(Err));
     halt(1);
   end;
 end;

Procedure CREATION_GRAPHISMES;
Begin
{ Chargement des polices }
  Assign(Font, 'TRIP.CHR');
  Reset(Font, 1);
  GetMem(FontT, FileSize(Font));
  BlockRead(Font, FontT^,FileSize(Font));
  if RegisterBGIfont(FontT) < 0 then
  begin
    WriteLn('An error occured while reading the font TRIP.CHR :');
    Writeln(GraphErrorMsg(GraphResult));
    Halt(1);
  end;
  Close(Font);
  Assign(Font, 'SANS.CHR');
  Reset(Font, 1);
  GetMem(FontS, FileSize(Font));
  BlockRead(Font, FontS^,FileSize(Font));
  if RegisterBGIfont(FontS) < 0 then
  begin
    WriteLn('An error occured while reading the font SANS.CHR :');
    Writeln(GraphErrorMsg(GraphResult));
    Halt(1);
  end;
  Close(Font);
{ Cration bloc }
 setcolor(lightblue);
 rectangle(10,10,30,30);
 rectangle(13,13,27,27);
 rectangle(17,17,23,23);
 line(10,30,30,10);
 SetFillStyle(1,lightblue);
 floodfill(15,15,lightblue);
 SetFillStyle(1,cyan);
 floodfill(22,22,lightblue);
 floodfill(11,11,lightblue);
 SetFillStyle(1,blue);
 floodfill(18,18,lightblue);
 floodfill(29,29,lightblue);
 setcolor(blue);
 line(10,30,30,30);
 line(30,30,30,10);
{ Cration fond }
 setcolor(Darkgray);
 rectangle(31,11,50,30);
 SetFillStyle(1,DarkGray);
 FloodFill(32,12,DarkGray);
 setcolor(Black);
 Circle(40,20,9);
 SetFillStyle(1,Black);
 FloodFill(40,20,Black);
 Setcolor(yellow);
 circle(37,18,1);
 circle(43,18,1);
 Setcolor(red);
 Arc(40,21,200,340,4);
{ Cration goutte }
 setcolor(red);
 rectangle(60,10,90,40);
 Arc(75,40,180,360,15);
 Arc(73,41,180,270,9);
 Arc(81,41,180,240,11);
 SetFillStyle(1,red);
 Floodfill(88,41,red);
 Floodfill(61,11,red);
 SetfillStyle(1,lightgray);
 FloodFill(69,44,red);
{ Cration flche }
 setcolor(lightblue);
 Line(140,135,148,140);
 Line(148,140,140,145);
 Line(140,145,160,145);
 Line(160,135,140,135);
 line(160,135,160,130);
 Line(160,130,175,140);
 Line(175,140,160,150);
 Line(160,150,160,145);
 SetFillStyle(1,lightblue);
 FloodFill(146,137,LightBlue);
{ Stockage en mmoire des blocs }
 Size := ImageSize(11, 11, 30, 30);
 GetMem(Bloc, Size);
 GetImage(11, 11, 30, 30, Bloc^);
 GetMem(fond, Size);
 GetImage(31, 11, 50, 30, fond^);
 GetMem(noir, Size);
 GetImage(101, 11, 120, 30, noir^);
 Size := ImageSize(60, 10, 90, 55);
 GetMem(goutte, Size);
 GetImage(60, 10, 90, 55, goutte^);
 Size := ImageSize(140, 130, 175, 150);
 GetMem(fleche, Size);
 GetImage(140, 130, 175, 150, fleche^);
end;

Procedure S(f,d:word);
Begin
  If son and not keypressed then
    begin
      sound(f);
      delay(d);
      nosound;
    end;
end;

Procedure VIDE_BUFFER_CLAVIER;
var Reg : registers;
begin
  Reg.ax:=$0C00;
  MsDos(Reg);
end;

Procedure CURSEUR(ok : boolean);
var Reg       : registers;
    NoCurseur : word;
begin
  NoCurseur:= $0207;
  Reg.Ax := $100;
  if ok then Reg.Cx := NoCurseur else Reg.Cx:=$F0F0;
  Intr($10,Reg)
end;

Procedure MENU;
Begin
ClearViewPort;
SetTextStyle(TriplexFont,HorizDir,4);
SetColor(Magenta);
OutTextXY(20,20,'SLItris');
SetTextStyle(TriplexFont,Horizdir,2);
OutTextXY(20,400,'by xxx, 19xx.');
SetTextStyle(SansSerifFont,HorizDir,3);
SetColor(yellow);
OutTextXY(130,90,'About...');
OutTextXY(130,125,'Play game');
OuttextXY(130,160,'Best scores');
OutTextXY(130,195,'Redefine keys');
OutTextXY(130,230,'Redefine parameters');
OutTextXY(130,265,'Initialise scores/keys/parameters');
OutTextXY(130,300,'Quit');
PosY:=1;
PutImage(60,62+35*PosY,fleche^,XorPut);
Vide_Buffer_Clavier;
Repeat
  Repeat until keypressed;
  touche:=readkey;
  PutImage(60,62+35*PosY,fleche^,XorPut);
  Case touche Of #80,'2' : inc(PosY);
                 #72,'8' : dec(PosY);
                 #27     : PosY:=7;
  end;
  if touche<>chr(13) then touche:=#0;
  If PosY>7 then PosY:=1;
  If PosY<1 then PosY:=7;
  PutImage(60,62+35*PosY,fleche^,XorPut);
Until (touche=#13);
End;

Procedure APROPOS;
Begin
TextMode(CO80);
TextBackGround(blue);
TextColor(LightGreen);
ClrScr;
Curseur(False);
Writeln('SLITRIS Release 1.0, another (yes, I know ...) Tetris.');
Writeln('Programmed by xxx, july 19xx. Freeware.');
TextColor(Yellow);
Writeln;
Writeln('Move the arrow in the menu with Up and Down, press Enter to select.');
writeln;
Writeln('The first time that you will play, you should redefine the keys and');
Writeln('parameters as you like them to be. Your choices will be saved on disk.');
Writeln('Cursor, Esc, F1, F2 et F3 are already used, so don''t redefine them.');
Writeln('Default keys : Up/5 rotate, Down/2 go down, Right/4 and Left/6 move block.');
Writeln;
Writeln('Keys that you can''t modify because they are used in the game are :');
Writeln('F1  pause the game (during the screen saver, keys + and');
Writeln('    - change the speed, press Esc to come back to game),');
Writeln('F2  enabled/disabled sound (look buzzer at bottom left),');
Writeln('F3  enabled/diasbled next block,');
Writeln('Esc to cancel the game.');
Writeln('Press any key to pass the musics.');
Vide_Buffer_Clavier;
Repeat until not keypressed;
Repeat until keypressed;
Curseur(true);
Init_Graph;
End;

Procedure AFFICHE_PROCHAIN;
Begin
{ Affichage score }
 For a:=1 to 5 do putimage(25+a*20,55,noir^,normalPut);
 Str(score,chaine);
 Setcolor(Lightmagenta);
 OutTextXY(47,52,chaine);
 Setcolor(White);
 OutTextXY(45,50,chaine);
{ Affichage prochain bloc }
 For a:=1 to 2 do
   For b:=1 to 4 do
     If pieces[num_prochain,a,b] and prochain
     then putimage(25+b*20,185+a*20,bloc^,normalPut)
     else putimage(25+b*20,185+a*20,noir^,normalPut);
End;

Procedure AFFICHE_LIGNES;
Begin
 For a:=1 to 4 do putimage(25+a*20,125,noir^,normalPut);
 Str(lignes,chaine);
 Setcolor(Lightmagenta);
 OutTextXY(47,122,chaine);
 Setcolor(White);
 OutTextXY(45,120,chaine);
end;

Procedure AFFICHE_NIVEAU;
Begin
 For a:=1 to 2 do putimage(52+a*20,315,noir^,normalPut);
 Str(11-niveau div 2,chaine);
 Setcolor(lightmagenta);
 OutTextXY(74,312,chaine);
 Setcolor(White);
 OutTextXY(72,310,chaine);
end;

Procedure AFFICHE_SON;
Begin
  If son then
    Begin
     son:=false;
     setcolor(black);
    end
    else
    Begin
     son:=true;
     setcolor(yellow)
    end;
 arc(68,420,110,250,5);
 arc(63,420,110,250,10);
 arc(58,420,110,250,18);
end;

Procedure AFFICHE_BLOC;
Begin
  For a:=1 to 4 do
    For b:=1 to 4 do
      If piece[a,b]
      then putimage(160+(posX+b)*20,(posY+a-2)*20,bloc^,normalPut);
end;

Procedure EFFACE_BLOC;
Begin
  For a:=1 to 4 do
    For b:=1 to 4 do
      If piece[a,b]
      then putimage(160+(posX+b)*20,(posY+a-2)*20,fond^,normalPut);
end;

Procedure AFFICHE_PLATEAU;
Begin
For a:=2 to 21 do
  For b:=2 to 11 do
    If Plateau[b,a]
    then putimage(180+b*20,(a-1)*20,bloc^,normalPut)
    else putimage(180+b*20,(a-1)*20,fond^,normalPut);
end;

Procedure INIT_ECRAN;
Begin
{ Cration du cadre }
 ClearViewPort;
 setcolor(lightgreen);
 line(200,0,440,0);
 line(200,0,200,440);
 line(200,440,219,420);
 line(219,420,219,19);
 line(219,19,420,19);
 line(420,19,440,0);
 setfillstyle(9,lightgreen);
 floodfill(230,10,lightgreen);
 setcolor(green);
 line(440,0,440,440);
 line(440,440,200,440);
 line(200,440,219,420);
 line(219,420,420,420);
 line(420,420,420,19);
 line(420,19,440,0);
 line(200,0,219,19);
 setfillstyle(9,green);
 floodfill(230,430,green);
 setcolor(lightgreen);
 line(420,420,440,440);
{ Ecriture des textes }
 setcolor(yellow);
 SetTextStyle(TriplexFont, HorizDir, 4);
 OutTextXY(485,30, 'SLItris');
 SetTextStyle(TriplexFont, HorizDir, 2);
 OutTextXY(485,65, 'Release 1.0');
 SetColor(magenta);
 SetTextStyle(TriplexFont, HorizDir, 1);
 OutTextXY(485,120, '  KEYS');
 OutTextXY(485,160, 'Esc : End');
 OutTextXY(485,190, 'F1  : Pause');
 OutTextXY(485,220, 'F2  : Sound');
 OutTextXY(485,250, 'F3  : Next');
 Setcolor(Red);
 SetTextStyle(SansSerifFont, HorizDir, 3);
 OutTextXY(45,20, 'Score');
 OutTextXY(45,90,'Lines');
 OutTextXY(45,160, 'Next');
 OutTextXY(45,280,'Level');
{ Icone son }
 setcolor(cyan);
 rectangle(80,410,95,430);
 line(70,400,70,440);
 line(80,410,70,400);
 line(70,440,80,430);
 If son then
   Begin
     setcolor(yellow);
     arc(68,420,110,250,5);
     arc(63,420,110,250,10);
     arc(58,420,110,250,18);
   End;
 SetTextStyle(TriplexFont, HorizDir, 3); { Police des affichages du jeu }
 SetFillStyle(11,LightMagenta); { Remplissage des lignes }
 Affiche_plateau;
 Affiche_lignes;
 Affiche_niveau;
 Vide_buffer_clavier;
end;

Procedure PAUSE;
Var  fins  : boolean;
     put_x:array[1..80] of integer;
     put_y:array[1..80] of integer;
     color:array[1..80] of byte;
begin
 b:=1;
 fins:=false;
 randomize;
 for a:=1 to 80 do
    begin
      put_x[a]:=random(640);
      put_y[a]:=random(480);
      color[a]:=random(5)+11;
      putpixel(put_x[a],put_y[a],color[a]);
    end;
 ClearViewPort;
 repeat
   if keypressed then
     begin
       touche:=readkey;
       Vide_Buffer_Clavier;
       case touche of
            #43 : if b<33 then inc(b);
            #45 : if b>1  then dec(b);
            #27 : fins:=true;
       end;
     end;
   for a:=1 to 80 do
   begin
     putpixel(put_x[a],put_y[a],black);
     if put_x[a]>640 div 2 then
       inc(put_x[a],abs((640 div 2-put_x[a]) div (40-b))+1)
       else
       dec(put_x[a],abs((640 div 2-put_x[a]) div (40-b))+1);
     if put_y[a]>480 div 2 then
       inc(put_y[a],abs((480 div 2-put_y[a]) div (40-b))+1)
       else
       dec(put_y[a],abs((480 div 2-put_y[a]) div (40-b))+1);
     if (put_x[a]<=0)or(put_x[a]>=640)or
       (put_y[a]<=0)or(put_y[a]>=480)then
       begin
         put_x[a]:=200+random(640 div 2 -100);
         put_y[a]:=150+random(480 div 2 -75);
       end;
     putpixel(put_x[a],put_y[a],color[a]);
   end;
   delay(vitesse);
 until fins;
 Init_ecran;
 Affiche_Bloc;
 Affiche_Prochain;
 setcolor(lightblue);
 OutTextXY(502,302, 'Pause');
 setcolor(Lightred);
 OutTextXY(500,300, 'Pause');
 repeat until keypressed;
 For a:=1 to 4 do putimage(480+a*20,306,noir^,normalPut);
 Vide_buffer_clavier;
End;

Procedure DROITE;
Begin
{ Teste si le mouvement est possible }
 ok:=true;
 For a:=1 to 4 do
   For b:=1 to 4 do
     If (piece[a,b]) and (plateau[posX+b,posY+a-1]) then ok:=false;
{ Si ok on effectue le mouvement }
 If ok then
   begin
     Efface_bloc;
     inc(posX);
     Affiche_bloc;
   end;
end;

Procedure GAUCHE;
Begin
{Teste si le mouvement est possible }
 ok:=true;
 For a:=1 to 4 do
   For b:=1 to 4 do
     If (piece[a,b]) and (plateau[posX+b-2,posY+a-1]) then ok:=false;
{ Si ok on effectue le mouvement }
 If ok then
   Begin
     Efface_bloc;
     dec(posX);
     Affiche_bloc;
   end;
end;

Procedure TOURNE;
Var piece_temp : tab_piece;
Begin
 ok:=true;
{ Test si la pice n'est pas un carr }
 If num_piece<>7 then
 { Simulation de rotation }
   Begin
     piece_temp:=pieces[8];
     piece_temp[2,2]:=piece[2,2];
     If fiche[10].option=0 then
       Begin
         piece_temp[1,1]:=piece[1,3];
         piece_temp[1,2]:=piece[2,3];
         piece_temp[1,3]:=piece[3,3];
         piece_temp[2,1]:=piece[1,2];
         piece_temp[2,3]:=piece[3,2];
         piece_temp[3,1]:=piece[1,1];
         piece_temp[3,2]:=piece[2,1];
         piece_temp[3,3]:=piece[3,1];
       end
       else
       begin
         piece_temp[1,1]:=piece[3,1];
         piece_temp[1,2]:=piece[2,1];
         piece_temp[1,3]:=piece[1,1];
         piece_temp[2,1]:=piece[3,2];
         piece_temp[2,3]:=piece[1,2];
         piece_temp[3,1]:=piece[3,3];
         piece_temp[3,2]:=piece[2,3];
         piece_temp[3,3]:=piece[1,3];
       end;
     piece_temp[4,2]:=piece[2,4]; { pour la barre }
     piece_temp[2,4]:=piece[4,2]; { pour la barre }
   { Teste si la rotation est possible }
     For a:=1 to 4 do
       For b:=1 to 4 do
         If (piece_temp[a,b]) and (plateau[posX+b-1,posY+a-1]) then ok:=false;
   { Si ok on valide la pice tourne }
     If ok then
       Begin
         Efface_bloc;
         piece:=piece_temp;
         Affiche_bloc;
       End;
   end;
End;

Procedure DESCENDRE_PIECE;
Begin
{ Teste si la descente est possible }
 ok:=true;
 For a:=1 to 4 do
   For b:=1 to 4 do
     If (piece[a,b]) and (plateau[posX+b-1,posY+a]) then ok:=false;
{ Si ok on effectue la descente }
 If ok then
   Begin
     Efface_bloc;
     inc(posY);
     Affiche_bloc;
   End;
End;

Procedure VIDE_LIGNES;
Var c,somme,l : byte;
Begin
 l:=0;
{ Test de la premire ligne }
 somme:=0;
 For a:=2 to 11 do if plateau[2,a] then inc(somme);
 if somme=10 then  { si elle est pleine }
   begin
     inc(l);       { on incrmente les lignes lignes }
     for a:=2 to 11 do plateau [2,a]:=false; { on la vide }
     Setcolor(white);
     Rectangle(220,20,419,39);
     FloodFill(230,30,white);
     if son then  { Signal d'une ligne pleine }
       begin
         sound(440);
         delay(50);
         nosound;
       end;
   end;
{ Test des autres lignes }
 For a:=21 downto 3 do
   begin
     somme:=0;
     For b:=2 to 11 do if plateau[b,a] then inc(somme);
     If (Cheat) and (l<4) then somme:=10;
     If somme=10 then { soit si la ligne est pleine }
       begin
         inc(l);
         for c:=a downto 3 do { 3 car sinon pb quand on copie la ligne du dessus }
           for b:=2 to 11 do
              plateau[b,c]:=plateau[b,c-1];    { on copie la ligne du dessus }
         for c:=2 to 11 do plateau[c,2]:=false;{ on vide la ligne du haut }
         Setcolor(white);
         Rectangle(220,(a-l+1)*20-1,419,(a-l)*20);
         FloodFill(230,(a-l)*20+10,white);
         inc(a);      { Si il y a une autre ligne … vider au dessus, elle est dcale sur la ligne courante }
         if son then  { Signal d'une ligne pleine }
           begin
             sound(440);
             delay(50);
             nosound;
           end;
       end;
   end;
{ Mise … jour du score }
{ Note : on rutilise SIZE comme incrment pour conomie de mmoire }
 Case l of 0 : size:=10;   { Bloc plac }
           1 : size:=110;  { Bouuuh  : simple }
           2 : size:=310;  { Bof     : double }
           3 : size:=610;  { Pas mal : triple }
           4 : size:=1010; { Ouaiiis : Tetris ! }
 end;
 Affiche_plateau;
 if ((Lignes+l)div 10-Lignes div 10=1) and ((Lignes div 10) mod 2=1) and (niveau>3) then
   Begin
     dec(niveau,2);  { Passage de niveau toutes les 20 lignes }
     if son then     { Signal passage de niveau }
       begin
         sound(880);
         delay(50);
         nosound;
       end;
     Affiche_niveau;
   end;
 inc(lignes,l);  { Mise … jour lignes }
 if l<>0 then Affiche_lignes;
 num_piece:=num_prochain;  { Test partie finie }
 piece:=pieces[num_piece];
 For b:=1 to 4 do If (piece[2,b]) and (plateau[4+b,3]) then perdu:=true;
 If Cheat then
            Begin
              for b:=1 to 9 do putimage(210+b*20,449,noir^,normalPut);
              Cheat:=false;
            End
          else inc(score,size); { Mise … jour score }
End;

Procedure SANG(N:byte);
Begin
If not keypressed then
  For i:=1 to N do
    For a:=1 to 7 do
      begin
        GY[a]:=GY[a]+random(15);
        putimage(GX[a],GY[a],goutte^,NormalPut);
        delay(28);
      end
end;

Procedure JOUER;
Begin
{ Initialisation des variables }
 Niveau:=22-Fiche[5].option*2;
 Hauteur:=Fiche[6].Option;
 Vitesse:=Fiche[7].option;
 If Fiche[8].option=1 then son:=true
                      else son:=false;
 If Fiche[9].option=1 then prochain:=true
                      else prochain:=false;
 For a:=1 to 12 do
   For b:=1 to 22 do
     Plateau[a,b]:=true;
 For a:=2 to 11 do
   For b:=2 to 21 do
     Plateau[a,b]:=false;
 If Hauteur>0 then
   For a:=21 downto 22-hauteur do
     For b:=1 to 5 do Plateau[random(9)+2,a]:=true;
 lignes:=0;
 score:=0;
 perdu:=false;
 randomize;
 num_prochain:=random(7)+1;
{ Initialisation cran graphique }
 Init_graph;
 Init_ecran;
{ Musique dbut }
 Vide_Buffer_Clavier;
 s(247,400);
 s(220,400);
 s(185,200);
 s(196,200);
 s(220,400);
 s(185,200);
 s(196,200);
 s(220,400);
 s(196,200);
 s(185,200);
 s(165,400);
{ Dbut partie }
If keypressed then
  Begin
    Touche:=readkey;
    if (touche='S') or (touche='s') then son:=true
    else son:=false;
    Affiche_son;
  end;
num_piece:=num_prochain;
piece:=pieces[num_piece];
Cheat:=false;
Vide_buffer_clavier;
 repeat
   randomize;
   num_prochain:=random(7)+1;
   posX:=6;
   posY:=2;
   Affiche_prochain;
   Affiche_bloc;
   repeat
     For i:=1 to niveau do
       Begin
         If keypressed then
           Begin
             touche:=readkey;
             Vide_Buffer_Clavier;
             If touche=Chr(Fiche[1].option) then touche:=#75;
             If touche=Chr(Fiche[2].option) then touche:=#77;
             If touche=Chr(Fiche[3].option) then touche:=#72;
             If touche=Chr(Fiche[4].option) then touche:=#80;
             Case touche of
                    #75 : Gauche;
                    #77 : Droite;
                    #72 : Tourne;
                    #80 : Descendre_piece;
                    #59 : Pause;
                    #27 : begin
                            perdu:=true;
                            ok:=false;
                            i:=niveau;
                          end;
                    #61 : If prochain then prochain:=false
                                      else prochain:=true;
                    #60 : affiche_son;
                   #118 : Begin
                            OutTextXY(244,445,'I saw that!');
                            cheat:=true;
                          End;
             End;
           End;
         affiche_bloc;
         delay(vitesse);
       End;
     if not perdu then Descendre_piece;
   until not ok;
   For a:=1 to 4 do
     For b:=1 to 4 do
       If (piece[a,b]) then plateau[posX+b-1,posY+a-1]:=true;
   Vide_Lignes;
   Vide_Buffer_Clavier; { Pour viter de bouger la pice qui va arriver }
 Until (perdu) or (score>=100000);
 Setcolor(LightRed);
 If score>=100000 then
   begin
      SetTextStyle(TriplexFont, HorizDir, 2);
      OutTextXY(450,360,'Let''s stop there');
      OutTextXY(450,400,'You''re too strong !');
   end
 else
   begin
     SetTextStyle(TriplexFont, HorizDir, 4);
     OutTextXY(460,370, 'Game Over');
     SetColor(red);
     arc(165,35,0,90,25);
     arc(230,25,0,180,10);
     arc(310,50,0,180,40);
     arc(400,30,0,180,20);
     arc(460,25,0,180,10);
     arc(560,40,0,180,30);
     arc(639,35,90,180,20);
     line(0,10,0,0);
     line(0,0,639,0);
     line(639,0,639,15);
     line(0,10,165,10);
     line(190,35,220,25);
     line(240,25,270,50);
     line(350,50,380,30);
     line(420,30,450,25);
     line(470,25,530,40);
     line(590,40,619,35);
     setfillstyle(1,red);
     floodfill(2,2,red);
     For size:=1 to 7 do GY[size]:=8;
     Vide_Buffer_Clavier;
     If son then Sound(196);
     Sang(4);
     Nosound;
     Delay(45);
     If son then Sound(196);
     Sang(4);
     Nosound;
     Delay(45);
     If son then Sound(196);
     Sang(2);
     Nosound;
     Delay(30);
     If son then Sound(196);
     Sang(4);
     Nosound;
     Delay(45);
     If son then Sound(233);
     Sang(3);
     Nosound;
     Delay(45);
     If son then Sound(220);
     Sang(2);
     Nosound;
     Delay(30);
     If son then Sound(220);
     Sang(3);
     Nosound;
     Delay(45);
     If son then Sound(196);
     Sang(2);
     Nosound;
     delay(30);
     If son then Sound(196);
     Sang(3);
     Nosound;
     delay(45);
     If son then Sound(185);
     Sang(2);
     Nosound;
     delay(30);
     If son then Sound(196);
     Sang(4);
     Nosound;
     Sang(5);
   end;
{ Fin de la partie }
 Vide_buffer_clavier;
 SetColor(Yellow);
 SetTextStyle(SansSerifFont,Horizdir,2);
 OutTextXY(220,450,'Press a key to leave');
 Repeat until not keypressed;
 repeat until keypressed;
 Vide_Buffer_Clavier;
end;

Procedure VOIR_SCORES;
Begin
TextMode(CO40);
TextBackGround(LightGray);
Curseur(False);
ClrScr;
TextColor(Magenta);
Writeln;
Writeln(' ษออออออออออออออออออออออออออออออออออออป');
Writeln(' บ    History will remember    ...    บ');
Writeln(' ศออออออออออออออออออออออออออออออออออออผ');
TextColor(Blue);
Writeln;
Writeln;
Writeln(' Rank        Name        Score Lines');
Writeln;
For i:=1 to 10 do
  With Fiche[i] do
    Begin
      if i<>10 then write(' ');
      Writeln('  ',i,'  ',Nom:16,'  ',Sco:6,'  ',lign:3);
    end;
TextColor(Brown);
GotoXY(4,24);
Write('Press a key to return to menu...');
Vide_Buffer_Clavier;
Repeat until not keypressed;
Repeat until keypressed;
Curseur(true);
Init_graph;
end;

Procedure NEW_HIGH;
Begin
  For a:=1 to 10 do
    If (score>fiche[a].sco) then
      Begin
        TextMode(CO40);
        TextBackGround(LightGray);
        Curseur(False);
        ClrScr;
        TextColor(Magenta);
        Writeln;
        Writeln(' ษออออออออออออออออออออออออออออออออออออป');
        Writeln(' บ    CONGRATULATIONS ! Nice job.     บ');
        Writeln(' ศออออออออออออออออออออออออออออออออออออผ');
        S(73,125 );     S(73,125);     S(73,125);
        S(98,400);      S(98,400);     S(110,400);
        S(110,400);     S(147,600);    S(123,200);
        S(98,200);      S(98,200);     S(123,200);
        S(98,200);      S(82,400);     S(131,800);
        S(110,200);     S(92,200);     S(98,1200);
        TextColor(Blue);
        Writeln;
        Writeln;
        Writeln('  Enter your name (16 letters max.) :');
        TextColor(Green);
        GotoXY(10,9);
        Repeat until not keypressed;
        Vide_Buffer_Clavier;
        if a<>10 then
        For b:=10 downto a+1 do
        Begin
          Fiche[b].Nom:=Fiche[b-1].Nom;
          Fiche[b].sco:=Fiche[b-1].Sco;
          Fiche[b].lign:=Fiche[b-1].Lign;
        End;
        With Fiche[a] do
          Begin
            Read(Nom);
            Lign:=Lignes;
            sco:=score;
          End;
        a:=10;
      end;
End;

Procedure SET_TOUCHES;
Begin
SetColor(Yellow);
SetTextStyle(SansSerifFont,HorizDir,3);
For i:=1 to 4 do Fiche[i].option:=0;
For i:=1 to 4 do
  Begin
    ClearViewPort;
    OutTextXY(170,200,'Press the key for');
    Case i of 1 : OutTextXY(380,200,'left');
              2 : OutTextXY(380,200,'right');
              3 : OutTextXY(380,200,'rotate block');
              4 : OutTextXY(380,200,'down');
    end;
    Vide_Buffer_Clavier;
    Repeat until keypressed;
    touche:=readkey;
    son:=false;
    for a:=1 to 4 do if (ord(touche)=Fiche[a].option) then son:=true;
    If (touche in ([#27,#59,#60,#61,#72,#75,#77,#80])) or (son) then
      Begin
        OuttextXY(200,300,'Key already used !');
        delay(1000);
        dec(i);
      end
    else Fiche[i].option:=ord(touche);
  end;
End;

Procedure SET_PARAM;
Begin
TextMode(CO40);
TextBackGround(LightGray);
Curseur(False);
ClrScr;
TextColor(Magenta);
Writeln;
Writeln(' ษออออออออออออออออออออออออออออออออออออป');
Writeln(' บ            Parameters              บ');
Writeln(' ศออออออออออออออออออออออออออออออออออออผ');
Writeln;
TextColor(Blue);
Writeln('  Starting level   (1 to 10) ?');
Writeln;
Writeln('  Starting height  (0 to 15) ?');
Writeln;
Writeln('  Speed (10:fast,10000:slow) ?');
Writeln;
Writeln('  Sounds and musics          ?');
Writeln;
Writeln('  Show next block            ?');
Writeln;
Writeln('  Rotation of the blocks     ?');
GotoXY(1,22);
Writeln(' Up and Down to choose a parameter,');
Writeln(' Right and Left to modify it,');
Write(' Enter to accept the values.');
TextColor(Green);
GotoXY(32,6);Write(Fiche[5].option);
GotoXY(32,8);Write(Fiche[6].option);
GotoXY(32,10);Write(Fiche[7].option);
GotoXY(32,12);
If Fiche[8].option=1 then Write('Yes')
                     else Write('No ');
GotoXY(32,14);
If Fiche[9].option=1 then Write('Yes')
                     else Write('No ');
GotoXY(32,16);
If Fiche[10].option=1 then Write('CW ')
                      else Write('CCW');
i:=6;
HighVideo;
GotoXY(32,6);
Write(Fiche[5].option);
Repeat
  Vide_Buffer_Clavier;
  Repeat until Keypressed;
  touche:=Readkey;
  LowVideo;
  GotoXY(32,i);
  Case i of 6..10 : Write(Fiche[i div 2 + 2].option,' ');
           12..14 : if (Fiche[i div 2 + 2].option)=1 then Write('Yes')
                                                     else Write('No ');
               16 : if (Fiche[10].option)=1 then Write('CW ')
                                            else Write('CCW');
  end;
  Case touche of #80,'2' : If i<16 then inc(i,2);
                 #72,'8' : If i>6 then Dec(i,2);
                 #75,'4' : Case i of 6 : If Fiche[5].option>1 then dec(Fiche[5].option);
                                     8 : If Fiche[6].option>0 then dec(Fiche[6].option);
                                    10 : If Fiche[7].option>10 then dec(Fiche[7].option,30);
                                else If Fiche[i div 2 + 2 ].option=0
                                     then Fiche[i div 2 + 2].option:=1
                                     else Fiche[i div 2 + 2].option:=0;
                                end;
                 #77,'6' : Case i of 6 : If Fiche[5].option<10 then inc(Fiche[5].option);
                                     8 : If Fiche[6].option<15 then inc(Fiche[6].option);
                                    10 : If Fiche[7].option<10000 then inc(Fiche[7].option,30);
                                else If Fiche[i div 2 + 2 ].option=0
                                     then Fiche[i div 2 + 2].option:=1
                                     else Fiche[i div 2 + 2].option:=0;
                                end;
              end;
  HighVideo;
  GotoXY(32,i);
  Case i of 6..10 : Write(Fiche[i div 2 + 2].option,' ');
           12..14 : if (Fiche[i div 2 + 2].option)=1 then Write('Yes')
                                                     else Write('No ');
               16 : if (Fiche[10].option)=1 then Write('CW ')
                                            else Write('CCW');
  end;

until touche=#13;
Curseur(true);
Init_graph;
End;

Procedure RESET_SCORES;
Begin
  For i:=1 to 10 do
    With Fiche[i] do
      Begin
        Nom:='None';
        Sco:=(11-i)*1000;
        Lign:=(11-i)*5;
        Case i Of 1 : Option:=52;   { Gauche }
                  2 : Option:=54;   { Droite }
                  3 : Option:=53;   { Tourne }
                  4 : Option:=50;   { Bas }
                  5 : Option:=1;    { Niveau de dpart }
                  6 : Option:=0;    { Hauteur de dpart }
                  7 : Option:=1000; { Vitesse = dure DELAY }
                  8 : Option:=0;    { Son : 1 actif, 0 passif }
                  9 : Option:=1;    { Prochain : 1 actif, 0 passif }
                 10 : Option:=0;    { Sens de rotation : 0 trigo, 1 horaire }
      end;
    end;
end;

BEGIN  { Programme Principal }
Init_Graph;
{ Test ici pour effectuer tout accs disque … la suite }
{$I-}
Assign(Fichier,'SLITRIS.DAT');
Reset(Fichier);
Close(Fichier);
{$I+}
If IOResult<>0 then RESET_SCORES
               else Begin
                      Reset(Fichier);
                      For a:=1 to 10 do read(Fichier,Fiche[a]);
                      Close(Fichier);
                    end;
Creation_Graphismes;
Repeat
  Menu;
  Case PosY of 1 : APropos;
               2 : Begin
                     Jouer;
                     New_High;
                     Voir_Scores;
                   End;
               3 : Voir_Scores;
               4 : Set_Touches;
               5 : Set_Param;
               6 : Reset_Scores;
  end;
until PosY=7;
CloseGraph;
ReWrite(fichier);
For b:=1 to 10 do Write(Fichier,Fiche[b]);
Close(Fichier);
LowVideo;
TextMode(Co80);
END.