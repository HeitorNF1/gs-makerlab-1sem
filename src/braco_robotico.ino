// ============================================================
//  Braço Robótico 
//  Disciplina: Project Based Maker Lab
//
//  Hardware:
//    - Arduino Uno
//    - Servo 1 (ombro/articulação principal) → pino 9
//    - Servo 2 (garra/abertura)              → pino 10
//    - LED de status                         → pino 13
//
//  Comandos via Monitor Serial (9600 baud):
//    U → Up   — move o ombro para CIMA    (90° → 150°)
//    D → Down — move o ombro para BAIXO   (90° → 30°)
//    O → Open — abre  a garra             (90° → 160°)
//    C → Close— fecha a garra             (90° → 20°)
//    R → Reset— retorna ambos ao centro   (90°)
// ============================================================

#include <Servo.h>

// ---------- pinos ----------
const int PIN_SERVO_OMBRO = 9;
const int PIN_SERVO_GARRA = 10;
const int PIN_LED         = 13;

// ---------- ângulos ----------
const int ANGULO_CENTRO       = 90;  // posição neutra (ambos os servos)

const int OMBRO_CIMA          = 150; // comando U
const int OMBRO_BAIXO         = 30;  // comando D

const int GARRA_ABERTA        = 160; // comando O
const int GARRA_FECHADA       = 20;  // comando C

// ---------- objetos ----------
Servo servoOmbro;
Servo servoGarra;

// ---------- estado atual ----------
int anguloOmbro = ANGULO_CENTRO;
int anguloGarra = ANGULO_CENTRO;

// ============================================================
void setup() {
  Serial.begin(9600);

  servoOmbro.attach(PIN_SERVO_OMBRO);
  servoGarra.attach(PIN_SERVO_GARRA);

  pinMode(PIN_LED, OUTPUT);
  
  

  // posição inicial — centro
  servoOmbro.write(anguloOmbro);
  servoGarra.write(anguloGarra);

  Serial.println("=== Braco Robotico Inicializado ===");
  Serial.println("Comandos: U (Up) | D (Down) | O (Open) | C (Close) | R (Reset)");
  Serial.println("Aguardando comando...");
  
  digitalWrite(PIN_LED, HIGH);
  delay(1000);
  digitalWrite(PIN_LED, LOW);
}

// ============================================================
void loop() {
  if (Serial.available() > 0) {

    char comando = Serial.read();  // lê um caractere do Monitor Serial

    // aceita letras minúsculas também
    comando = toupper(comando);

    // ignora Enter e espaços
    if (comando == '\n' || comando == '\r' || comando == ' ') return;

    // acende LED ao receber qualquer comando válido
    piscarLED();

    switch (comando) {

      case 'U':  // Up — sobe o ombro
      	
        anguloOmbro = OMBRO_CIMA;
        servoOmbro.write(anguloOmbro);
        Serial.print(">> Ombro CIMA: ");
        Serial.print(anguloOmbro);
        Serial.println(" graus");
        break;

      case 'D':  // Down — desce o ombro
        anguloOmbro = OMBRO_BAIXO;
        servoOmbro.write(anguloOmbro);
        Serial.print(">> Ombro BAIXO: ");
        Serial.print(anguloOmbro);
        Serial.println(" graus");
        break;

      case 'O':  // Open — abre a garra
        anguloGarra = GARRA_ABERTA;
        servoGarra.write(anguloGarra);
        Serial.print(">> Garra ABERTA: ");
        Serial.print(anguloGarra);
        Serial.println(" graus");
        break;

      case 'C':  // Close — fecha a garra
        anguloGarra = GARRA_FECHADA;
        servoGarra.write(anguloGarra);
        Serial.print(">> Garra FECHADA: ");
        Serial.print(anguloGarra);
        Serial.println(" graus");
        break;

      case 'R':  // Reset — retorna ao centro
        anguloOmbro = ANGULO_CENTRO;
        anguloGarra = ANGULO_CENTRO;
        servoOmbro.write(anguloOmbro);
        servoGarra.write(anguloGarra);
        Serial.println(">> RESET — ambos os servos em 90 graus");
        break;

      default:
        // comando desconhecido
        digitalWrite(PIN_LED, LOW);
        Serial.print("!! Comando invalido: '");
        Serial.print(comando);
        Serial.println("'  |  Use: U D O C R");
        return;  // sai sem piscar LED
    }
  }
}

// ============================================================
// Função auxiliar: pisca o LED 1x para confirmar o comando
// ============================================================
void piscarLED() {
  digitalWrite(PIN_LED, HIGH);
  delay(200);
  digitalWrite(PIN_LED, LOW);
}
