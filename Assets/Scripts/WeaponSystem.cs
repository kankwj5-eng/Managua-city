using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class WeaponSystem : MonoBehaviour
{
    [System.Serializable]
    public class Weapon
    {
        public string weaponName;
        public enum WeaponType { Melee, Pistol, Rifle }
        public WeaponType type;
        public float damage = 25f;
        public float range = 100f;
        public int maxAmmo = 30;
        public int currentAmmo = 30;
        public int totalReserveAmmo = 90;
        public float fireRate = 0.5f; // time between shots
        public float reloadTime = 1.5f;
        public bool isAutomatic = false;
        public Transform muzzlePoint;
    }

    [Header("Weapons Setup")]
    public List<Weapon> inventory = new List<Weapon>();
    public int currentWeaponIndex = 0;

    [Header("Effects")]
    public GameObject muzzleFlashPrefab;
    public GameObject hitEffectPrefab;

    private float nextTimeToFire = 0f;
    private bool isReloading = false;

    void Start()
    {
        // Initialize default inventory if empty
        if (inventory.Count == 0)
        {
            Weapon machete = new Weapon { weaponName = "Machete", type = Weapon.WeaponType.Melee, damage = 40f, range = 2f, maxAmmo = 0, currentAmmo = 0, totalReserveAmmo = 0, fireRate = 0.8f, reloadTime = 0f };
            Weapon makarov = new Weapon { weaponName = "Makarov Pistol", type = Weapon.WeaponType.Pistol, damage = 25f, range = 40f, maxAmmo = 8, currentAmmo = 8, totalReserveAmmo = 32, fireRate = 0.4f, reloadTime = 1.2f };
            Weapon ak47 = new Weapon { weaponName = "AK-47", type = Weapon.WeaponType.Rifle, damage = 45f, range = 150f, maxAmmo = 30, currentAmmo = 30, totalReserveAmmo = 90, fireRate = 0.1f, reloadTime = 2.0f, isAutomatic = true };

            inventory.Add(machete);
            inventory.Add(makarov);
            inventory.Add(ak47);
        }
    }

    public void Shoot()
    {
        if (isReloading || inventory.Count == 0) return;
        if (Time.time < nextTimeToFire) return;

        Weapon activeWeapon = inventory[currentWeaponIndex];

        if (activeWeapon.type != Weapon.WeaponType.Melee && activeWeapon.currentAmmo <= 0)
        {
            Reload();
            return;
        }

        nextTimeToFire = Time.time + activeWeapon.fireRate;

        if (activeWeapon.type != Weapon.WeaponType.Melee)
        {
            activeWeapon.currentAmmo--;
        }

        // Spawn Muzzle Flash
        if (activeWeapon.muzzlePoint != null && muzzleFlashPrefab != null)
        {
            Instantiate(muzzleFlashPrefab, activeWeapon.muzzlePoint.position, activeWeapon.muzzlePoint.rotation);
        }

        // Raycast shooting (GTA mechanics)
        Camera mainCam = Camera.main;
        Vector3 rayOrigin = mainCam != null ? mainCam.transform.position : transform.position;
        Vector3 rayDirection = mainCam != null ? mainCam.transform.forward : transform.forward;

        RaycastHit hit;
        if (Physics.Raycast(rayOrigin, rayDirection, out hit, activeWeapon.range))
        {
            Debug.Log("Hit: " + hit.collider.name + " with " + activeWeapon.weaponName);

            // Handle hitting enemies
            EnemyAI enemy = hit.collider.GetComponentInParent<EnemyAI>();
            if (enemy != null)
            {
                enemy.TakeDamage(activeWeapon.damage);
            }

            // Spawn hit particle effect
            if (hitEffectPrefab != null)
            {
                Instantiate(hitEffectPrefab, hit.point, Quaternion.LookRotation(hit.normal));
            }
        }
    }

    public void Reload()
    {
        if (isReloading || inventory.Count == 0) return;

        Weapon activeWeapon = inventory[currentWeaponIndex];
        if (activeWeapon.type == Weapon.WeaponType.Melee) return;
        if (activeWeapon.currentAmmo == activeWeapon.maxAmmo) return;
        if (activeWeapon.totalReserveAmmo <= 0) return;

        StartCoroutine(ReloadRoutine(activeWeapon));
    }

    private IEnumerator ReloadRoutine(Weapon weapon)
    {
        isReloading = true;
        Debug.Log("Reloading: " + weapon.weaponName);

        yield return new WaitForSeconds(weapon.reloadTime);

        int neededAmmo = weapon.maxAmmo - weapon.currentAmmo;
        int ammoToTransfer = Mathf.Min(neededAmmo, weapon.totalReserveAmmo);

        weapon.currentAmmo += ammoToTransfer;
        weapon.totalReserveAmmo -= ammoToTransfer;

        isReloading = false;
        Debug.Log("Reload complete!");
    }

    public void SwitchWeapon(int index)
    {
        if (isReloading) return;
        if (index < 0 || index >= inventory.Count) return;

        currentWeaponIndex = index;
        Debug.Log("Switched weapon to: " + inventory[currentWeaponIndex].weaponName);
    }

    public void AddReserveAmmo(string weaponName, int amount)
    {
        foreach (var weapon in inventory)
        {
            if (weapon.weaponName.ToLower().Contains(weaponName.ToLower()))
            {
                weapon.totalReserveAmmo += amount;
                break;
            }
        }
    }

    public Weapon GetActiveWeapon()
    {
        if (inventory.Count == 0) return null;
        return inventory[currentWeaponIndex];
    }
}
