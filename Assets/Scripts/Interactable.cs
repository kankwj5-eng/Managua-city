using UnityEngine;

public class Interactable : MonoBehaviour
{
    public enum InteractionType { Vehicle, ItemPickup, Clue, HealthPack, AmmoPack }
    public InteractionType type;

    [Header("Interaction Details")]
    public string promptMessage = "Presiona E para interactuar";
    public string itemName = "Objeto";
    public int ammoAmount = 30;
    public float healthAmount = 35f;

    [Header("Clue Specifics")]
    [TextArea(3, 5)]
    public string clueText = "";
    public int clueID = 0;

    public void Interact(PlayerController player)
    {
        switch (type)
        {
            case InteractionType.Vehicle:
                VehicleController vehicle = GetComponent<VehicleController>();
                if (vehicle != null && !vehicle.isBeingDriven)
                {
                    player.EnterVehicle(vehicle, vehicle.exitPoint);
                    vehicle.OnPlayerEnter();
                    Debug.Log("Entered vehicle: " + name);

                    // Trigger UI notification
                    UIManager ui = FindObjectOfType<UIManager>();
                    if (ui != null) ui.ShowNotification("Conduciendo vehículo. Presiona E para salir.");
                }
                break;

            case InteractionType.ItemPickup:
                Debug.Log("Picked up item: " + itemName);
                // Trigger dialogue or message
                DialogueManager dm = FindObjectOfType<DialogueManager>();
                if (dm != null)
                {
                    dm.ShowDialogue("Lenner", "He encontrado un objeto útil: " + itemName);
                }
                Destroy(gameObject);
                break;

            case InteractionType.Clue:
                Debug.Log("Found clue ID: " + clueID);
                // Report to MissionManager
                MissionManager mm = FindObjectOfType<MissionManager>();
                if (mm != null)
                {
                    mm.OnClueFound(clueID);
                }
                // Show dialogue explaining the clue
                DialogueManager dialogue = FindObjectOfType<DialogueManager>();
                if (dialogue != null)
                {
                    dialogue.ShowDialogue("Lenner (Analizando pista)", clueText);
                }
                Destroy(gameObject);
                break;

            case InteractionType.HealthPack:
                if (player.currentHealth < player.maxHealth)
                {
                    player.Heal(healthAmount);
                    Debug.Log("Healed player by " + healthAmount);
                    Destroy(gameObject);
                }
                break;

            case InteractionType.AmmoPack:
                WeaponSystem ws = player.GetComponent<WeaponSystem>();
                if (ws != null)
                {
                    ws.AddReserveAmmo(itemName, ammoAmount);
                    Debug.Log("Added ammo to inventory: " + ammoAmount);
                    Destroy(gameObject);
                }
                break;
        }
    }
}
