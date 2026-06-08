// ============================================================
//  Braço Robótico de Coleta de Amostras — Docking & Retrieval
//  Modelo 3D: Garra (Grip) com encaixe para Servo 9g
//  Software: OpenSCAD
//
//  Como usar:
//    - Ajuste as variáveis abaixo para modificar o tamanho
//    - Pressione F5 para preview, F6 para render completo
//    - Exporte em File > Export > Export as STL
// ============================================================


// ============================================================
//  VARIÁVEIS GLOBAIS — ajuste aqui para redimensionar a peça
// ============================================================

// --- Servo 9g (dimensões reais do SG90) ---
servo_comp   = 23;   // comprimento do corpo do servo (mm)
servo_larg   = 12;   // largura do corpo do servo (mm)
servo_alt    = 22;   // altura do corpo do servo (mm)
servo_eixo_d = 5;    // diâmetro do eixo do servo (mm)

// --- Base da garra ---
base_comp    = 60;   // comprimento da base (mm)
base_larg    = 30;   // largura da base (mm)
base_alt     = 8;    // espessura da base (mm)

// --- Dedos da garra ---
dedo_comp    = 40;   // comprimento de cada dedo (mm)
dedo_larg    = 8;    // largura de cada dedo (mm)
dedo_alt     = 6;    // espessura de cada dedo (mm)
dedo_curva   = 15;   // ângulo de curvatura da ponta (graus)
abertura     = 18;   // distância entre os dedos (mm)

// --- Detalhes estéticos ---
chanfro      = 1.5;  // arredondamento das arestas (mm)
furo_alivio  = 4;    // diâmetro dos furos de alívio de peso (mm)

// --- Braço de ligação ---
braco_comp   = 35;   // comprimento do elo de ligação (mm)
braco_larg   = 14;   // largura do elo (mm)
braco_alt    = 6;    // espessura do elo (mm)

$fn = 40;  // qualidade dos cilindros (aumentar = mais suave, mais lento)


// ============================================================
//  MONTAGEM COMPLETA
// ============================================================
montagem_completa();

module montagem_completa() {
    // base central com encaixe do servo
    base_garra();

    // dedo esquerdo
    translate([-abertura/2 - dedo_larg/2, base_comp/2 - 5, 0])
        dedo();

    // dedo direito (espelhado)
    translate([abertura/2 + dedo_larg/2, base_comp/2 - 5, 0])
        mirror([1, 0, 0])
            dedo();

    // elo de ligação traseiro
    translate([0, -base_comp/2 - braco_comp/2 + 5, 0])
        elo_ligacao();
}


// ============================================================
//  BASE DA GARRA com encaixe para servo 9g
// ============================================================
module base_garra() {
    difference() {
        // corpo principal da base
        union() {
            // bloco base com chanfro
            minkowski() {
                cube([base_larg - 2*chanfro,
                      base_comp - 2*chanfro,
                      base_alt  - chanfro], center=true);
                cylinder(r=chanfro, h=chanfro/2);
            }

            // reforço central (nervura superior)
            translate([0, 0, base_alt/2])
                cube([base_larg * 0.4, base_comp * 0.6, 4], center=true);
        }

        // --- cavidade para encaixe do servo 9g ---
        translate([0, 0, base_alt/2 - servo_alt/2 + 2])
            cube([servo_larg + 0.4,
                  servo_comp + 0.4,
                  servo_alt], center=true);

        // furo do eixo do servo
        translate([0, 0, base_alt])
            cylinder(d=servo_eixo_d + 0.5, h=10, center=true);

        // furos de alívio de peso (reduz massa — importante em microgravidade)
        for(x = [-1, 1]) {
            for(y = [-1, 1]) {
                translate([x * base_larg/4, y * base_comp/4, 0])
                    cylinder(d=furo_alivio, h=base_alt + 2, center=true);
            }
        }

        // canal para passagem dos fios do servo
        translate([0, -base_comp/2, base_alt/4])
            cube([6, 10, 5], center=true);
    }
}


// ============================================================
//  DEDO DA GARRA (com ponta curvada para captura de amostra)
// ============================================================
module dedo() {
    difference() {
        union() {
            // segmento reto do dedo
            translate([0, dedo_comp/4, dedo_alt/2])
                cube([dedo_larg, dedo_comp/2, dedo_alt], center=true);

            // ponta curvada (simula adaptação para microgravidade)
            translate([0, dedo_comp/2, dedo_alt/2])
                rotate([0, 0, 0])
                    rotate_extrude(angle=dedo_curva, $fn=20)
                        translate([dedo_larg/2, 0, 0])
                            square([dedo_larg * 0.6, dedo_alt], center=true);

            // base de fixação (conecta ao corpo)
            translate([0, 0, dedo_alt/2])
                cube([dedo_larg + 4, 12, dedo_alt], center=true);

            // nervura de reforço longitudinal
            translate([0, dedo_comp/4, dedo_alt])
                cube([dedo_larg * 0.3, dedo_comp/2, 2], center=true);
        }

        // furo de fixação na base (parafuso M3)
        translate([0, 0, 0])
            cylinder(d=3.2, h=dedo_alt * 3, center=true);

        // chanfro na ponta para não marcar a amostra
        translate([0, dedo_comp * 0.6, dedo_alt])
            rotate([45, 0, 0])
                cube([dedo_larg + 2, 4, 4], center=true);
    }
}


// ============================================================
//  ELO DE LIGAÇÃO (conecta a garra ao braço / servo de ombro)
// ============================================================
module elo_ligacao() {
    difference() {
        union() {
            // corpo do elo
            minkowski() {
                cube([braco_larg - 2*chanfro,
                      braco_comp - 2*chanfro,
                      braco_alt  - chanfro], center=true);
                cylinder(r=chanfro, h=chanfro/2);
            }

            // olhal de fixação (extremidade distal)
            translate([0, braco_comp/2, 0])
                cylinder(d=braco_larg, h=braco_alt, center=true);

            // olhal de fixação (extremidade proximal)
            translate([0, -braco_comp/2, 0])
                cylinder(d=braco_larg, h=braco_alt, center=true);
        }

        // furo proximal (eixo do servo de ombro — M3 passante)
        translate([0, -braco_comp/2, 0])
            cylinder(d=servo_eixo_d + 0.5, h=braco_alt + 2, center=true);

        // furo distal (parafuso de fixação na base da garra — M3)
        translate([0, braco_comp/2, 0])
            cylinder(d=3.2, h=braco_alt + 2, center=true);

        // slot central de alívio
        cube([braco_larg * 0.35, braco_comp * 0.5, braco_alt + 2], center=true);

        // gravação de identificação (cosmético)
        translate([0, 0, braco_alt/2])
            linear_extrude(height=0.8)
                text("SRB-01", size=4, halign="center", valign="center",
                     font="Liberation Sans:style=Bold");
    }
}
