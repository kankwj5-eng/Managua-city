using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    [Header("UI Elements")]
    public Text healthText;
    public Text staminaText;
    public Text weaponText;
    public Text ammoText;
    public Text missionText;
    public Text notificationText;

    [Header("Panels")]
    public GameObject gameOverPanel;
    public GameObject gameWinPanel;

    private PlayerController player;
    private WeaponSystem weaponSystem;
    private float notificationTimer = 0f;

    void Start()
    {
        GameObject playerObj = GameObject.FindWithTag("Player");
        if (playerObj != null)
        {
            player = playerObj.GetComponent<PlayerController>();
            weaponSystem = playerObj.GetComponent<WeaponSystem>();
        }

        if (gameOverPanel != null) gameOverPanel.SetActive(false);
        if (gameWinPanel != null) gameWinPanel.SetActive(false);
        if (notificationText != null) notificationText.enabled = false;
    }

    void Update()
    {
        UpdateHUD();
        HandleNotificationTimer();
    }

    void UpdateHUD()
    {
        if (player != null)
        {
            if (healthText != null)
            {
                healthText.text = $"VIDA: {Mathf.CeilToInt(player.currentHealth)}%";
            }

            if (staminaText != null)
            {
                staminaText.text = $"STAMINA: {Mathf.CeilToInt(player.currentStamina)}%";
            }
        }

        if (weaponSystem != null && weaponSystem.inventory.Count > 0)
        {
            var activeWeapon = weaponSystem.GetActiveWeapon();
            if (activeWeapon != null)
            {
                if (weaponText != null)
                {
                    weaponText.text = $"ARMA: {activeWeapon.weaponName}";
                }

                if (ammoText != null)
                {
                    if (activeWeapon.type == WeaponSystem.Weapon.WeaponType.Melee)
                    {
                        ammoText.text = "MUNICIÓN: -- / --";
                    }
                    else
                    {
                        ammoText.text = $"MUNICIÓN: {activeWeapon.currentAmmo} / {activeWeapon.totalReserveAmmo}";
                    }
                }
            }
        }
    }

    public void UpdateMissionText(string text)
    {
        if (missionText != null)
        {
            missionText.text = text;
        }
    }

    public void ShowNotification(string message, float duration = 3.5f)
    {
        if (notificationText != null)
        {
            notificationText.text = message;
            notificationText.enabled = true;
            notificationTimer = duration;
        }
    }

    void HandleNotificationTimer()
    {
        if (notificationTimer > 0f)
        {
            notificationTimer -= Time.deltaTime;
            if (notificationTimer <= 0f && notificationText != null)
            {
                notificationText.enabled = false;
            }
        }
    }

    public void ShowGameOverScreen()
    {
        if (gameOverPanel != null)
        {
            gameOverPanel.SetActive(true);
        }
    }

    public void ShowWinScreen()
    {
        if (gameWinPanel != null)
        {
            gameWinPanel.SetActive(true);
        }
    }
}
