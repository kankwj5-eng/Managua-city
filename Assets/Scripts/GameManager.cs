using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public enum GameState { Menu, Playing, Paused, GameOver, Win }
    public GameState currentState = GameState.Playing;

    [Header("Spawn Configuration")]
    public GameObject playerPrefab; // fallback prefab
    public Transform spawnPoint;
    public GameObject cityPrefab; // managua_ciudad.glb as prefab

    private PlayerController playerInstance;
    private UIManager ui;

    void Awake()
    {
        InitializeGameWorld();
    }

    void Start()
    {
        ui = FindObjectOfType<UIManager>();
    }

    void Update()
    {
        HandleKeyboardGlobalInput();
    }

    void InitializeGameWorld()
    {
        Debug.Log("Initializing Managua City: El Camino de la Verdad...");

        // Try to automatically locate or load player models and city environment models
        GameObject city = GameObject.Find("managua_ciudad") ?? GameObject.FindWithTag("Environment");
        if (city == null && cityPrefab != null)
        {
            city = Instantiate(cityPrefab, Vector3.zero, Quaternion.identity);
            city.name = "managua_ciudad";
        }

        GameObject playerObj = GameObject.FindWithTag("Player");
        if (playerObj == null)
        {
            if (playerPrefab != null)
            {
                Vector3 spawnPos = spawnPoint != null ? spawnPoint.position : new Vector3(0, 1f, 0);
                Quaternion spawnRot = spawnPoint != null ? spawnPoint.rotation : Quaternion.identity;
                playerObj = Instantiate(playerPrefab, spawnPos, spawnRot);
                playerObj.name = "Lenner";
                playerObj.tag = "Player";
            }
            else
            {
                // Look for character model personnage_relieve in scene
                playerObj = GameObject.Find("personaje_relieve") ?? GameObject.Find("Lenner");
                if (playerObj != null)
                {
                    playerObj.tag = "Player";
                }
            }
        }

        if (playerObj != null)
        {
            playerInstance = playerObj.GetComponent<PlayerController>();
            if (playerInstance == null)
            {
                playerInstance = playerObj.AddComponent<PlayerController>();
            }

            // Ensure CharacterController is configured
            CharacterController cc = playerObj.GetComponent<CharacterController>();
            if (cc == null)
            {
                cc = playerObj.AddComponent<CharacterController>();
                cc.center = new Vector3(0, 1f, 0);
                cc.height = 2f;
                cc.radius = 0.5f;
            }

            // Ensure WeaponSystem is assigned
            WeaponSystem ws = playerObj.GetComponent<WeaponSystem>();
            if (ws == null)
            {
                playerObj.AddComponent<WeaponSystem>();
            }
        }
    }

    void HandleKeyboardGlobalInput()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (currentState == GameState.Playing)
            {
                PauseGame();
            }
            else if (currentState == GameState.Paused)
            {
                ResumeGame();
            }
        }

        // Restart hotkey when game over
        if (currentState == GameState.GameOver && Input.GetKeyDown(KeyCode.R))
        {
            RestartGame();
        }
    }

    public void PauseGame()
    {
        currentState = GameState.Paused;
        Time.timeScale = 0f;
        Debug.Log("Game Paused");
    }

    public void ResumeGame()
    {
        currentState = GameState.Playing;
        Time.timeScale = 1f;
        Debug.Log("Game Resumed");
    }

    public void GameOver()
    {
        currentState = GameState.GameOver;
        Time.timeScale = 0f;
        Debug.Log("Game Over!");

        if (ui != null)
        {
            ui.ShowGameOverScreen();
        }
    }

    public void WinGame()
    {
        currentState = GameState.Win;
        Time.timeScale = 0.5f; // Cool slow-mo effect on win
        Debug.Log("Congratulations! You found the truth.");

        if (ui != null)
        {
            ui.ShowWinScreen();
        }
    }

    public void RestartGame()
    {
        Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }
}
