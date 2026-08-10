using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MissionManager : MonoBehaviour
{
    public enum MissionID { Mission1, Mission2, Mission3, Mission4, Complete }
    public MissionID currentMission = MissionID.Mission1;

    [Header("Mission 1 Targets (Apartamento Científico)")]
    public int cluesNeededM1 = 2;
    private int cluesFoundM1 = 0;

    [Header("Mission 2 Targets (Escape de Managua)")]
    public Transform escapeCheckpoint;
    public float escapeDistanceThreshold = 5f;

    [Header("Mission 3 Targets (La Emboscada)")]
    public int enemiesToKillM3 = 4;
    private int enemiesKilledM3 = 0;

    [Header("Mission 4 Targets (El Secreto/Coordenadas)")]
    public int finalClueID = 99;
    private bool finalClueFound = false;

    private PlayerController player;
    private DialogueManager dialogue;
    private UIManager ui;

    void Start()
    {
        GameObject playerObj = GameObject.FindWithTag("Player");
        if (playerObj != null)
        {
            player = playerObj.GetComponent<PlayerController>();
        }

        dialogue = FindObjectOfType<DialogueManager>();
        ui = FindObjectOfType<UIManager>();

        StartCoroutine(StartIntroMissionSequence());
    }

    void Update()
    {
        CheckMissionUpdate();
    }

    IEnumerator StartIntroMissionSequence()
    {
        yield return new WaitForSeconds(1.5f);
        if (dialogue != null)
        {
            dialogue.ShowDialogue("Hermana (Último Mensaje)", "“No confíes en nadie. Yo tengo las respuestas… pero si me encuentran, todo habrá terminado.”");
            yield return new WaitForSeconds(4f);
            dialogue.ShowDialogue("Lenner", "¡No! ¡La llamada se cortó! Tengo que ir a su laboratorio abandonado aquí en Managua. Debe haber pistas...");
        }

        UpdateMissionHUD();
    }

    void CheckMissionUpdate()
    {
        if (player == null) return;

        switch (currentMission)
        {
            case MissionID.Mission1:
                if (cluesFoundM1 >= cluesNeededM1)
                {
                    StartCoroutine(TransitionToMission2());
                }
                break;

            case MissionID.Mission2:
                if (escapeCheckpoint != null)
                {
                    float distance = Vector3.Distance(player.transform.position, escapeCheckpoint.position);
                    if (distance < escapeDistanceThreshold)
                    {
                        StartCoroutine(TransitionToMission3());
                    }
                }
                break;

            case MissionID.Mission3:
                if (enemiesKilledM3 >= enemiesToKillM3)
                {
                    StartCoroutine(TransitionToMission4());
                }
                break;

            case MissionID.Mission4:
                if (finalClueFound)
                {
                    FinishGame();
                }
                break;
        }
    }

    public void OnClueFound(int id)
    {
        if (currentMission == MissionID.Mission1)
        {
            cluesFoundM1++;
            UpdateMissionHUD();
            if (dialogue != null)
            {
                dialogue.ShowDialogue("Lenner", "He encontrado un registro científico de mi hermana. Dice que alguien la perseguía por descubrir el origen de la inestabilidad.");
            }
        }
        else if (currentMission == MissionID.Mission4 && id == finalClueID)
        {
            finalClueFound = true;
        }
    }

    public void OnEnemyKilled(EnemyAI enemy)
    {
        if (currentMission == MissionID.Mission3)
        {
            enemiesKilledM3++;
            UpdateMissionHUD();
            if (dialogue != null && enemiesKilledM3 < enemiesToKillM3)
            {
                dialogue.ShowDialogue("Lenner", $"¡Toma eso! Faltan {enemiesToKillM3 - enemiesKilledM3} agentes enemigos.");
            }
        }
    }

    IEnumerator TransitionToMission2()
    {
        currentMission = MissionID.Complete; // Temp locks update
        yield return new WaitForSeconds(1f);

        if (dialogue != null)
        {
            dialogue.ShowDialogue("Lenner", "¡Listo! He conseguido las pistas necesarias. Revelan una dirección fuera de la zona segura. Los agentes del caos vienen en camino, ¡tengo que escapar de Managua!");
        }

        currentMission = MissionID.Mission2;
        UpdateMissionHUD();
    }

    IEnumerator TransitionToMission3()
    {
        currentMission = MissionID.Complete;
        yield return new WaitForSeconds(1f);

        if (dialogue != null)
        {
            dialogue.ShowDialogue("Lenner", "¡Rayos! Es una emboscada en la carretera. Varios enemigos armados me están cortando el paso. ¡Tengo que neutralizarlos!");
        }

        currentMission = MissionID.Mission3;
        UpdateMissionHUD();

        // Spawn or activate wave of enemies
        SpawnEnemyWave();
    }

    void SpawnEnemyWave()
    {
        Debug.Log("Spawning waves of agents searching for Lenner's sister...");
        // In actual play, you'd instantiate enemy prefabs near the player.
    }

    IEnumerator TransitionToMission4()
    {
        currentMission = MissionID.Complete;
        yield return new WaitForSeconds(1f);

        if (dialogue != null)
        {
            dialogue.ShowDialogue("Lenner", "Con la emboscada derrotada, el camino está libre. La última pista me lleva a este contenedor secreto. Debo hackearlo para descubrir las coordenadas finales de mi hermana.");
        }

        currentMission = MissionID.Mission4;
        UpdateMissionHUD();
    }

    void FinishGame()
    {
        currentMission = MissionID.Complete;
        if (dialogue != null)
        {
            dialogue.ShowDialogue("Lenner (La Verdad)", "¡Lo tengo! Sus coordenadas apuntan hacia las profundidades de la selva... Ella está viva y con el código de detención. ¡La verdadera aventura apenas comienza!");
        }

        GameManager gm = FindObjectOfType<GameManager>();
        if (gm != null)
        {
            gm.WinGame();
        }
    }

    void UpdateMissionHUD()
    {
        if (ui == null) return;

        string description = "";
        switch (currentMission)
        {
            case MissionID.Mission1:
                description = $"Misión 1: La Última Llamada\nInvestiga el laboratorio abandonado. Pistas encontradas: {cluesFoundM1}/{cluesNeededM1}";
                break;
            case MissionID.Mission2:
                description = "Misión 2: Escape de Managua\nBusca un auto o muévete rápido. Llega al punto de control de salida.";
                break;
            case MissionID.Mission3:
                description = $"Misión 3: La Emboscada\nNeutraliza a los agentes que te persiguen. Eliminados: {enemiesKilledM3}/{enemiesToKillM3}";
                break;
            case MissionID.Mission4:
                description = "Misión 4: El Secreto Revelado\nEncuentra las coordenadas finales de tu hermana en el cofre secreto.";
                break;
            case MissionID.Complete:
                description = "¡Misiones completadas!";
                break;
        }

        ui.UpdateMissionText(description);
    }
}
