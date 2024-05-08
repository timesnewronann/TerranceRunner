using UnityEngine;
using UnityEngine.AI;

public class EnemyAi : MonoBehaviour
{
    // Reference to the NavMeshAgent, used for enemy movement
    public NavMeshAgent agent;

    // References to the player's transform and the projectile spawn point
    public Transform player;
    public Transform projectileSpawnPoint; // New reference to the spawn point

    // Layers defining what is considered ground or a player for detection purposes
    public LayerMask whatIsGround, whatIsPlayer;

    // The health value of the enemy
    public float health;

    // Patroling variables
    public Vector3 walkPoint;          // Destination point for patrolling
    bool walkPointSet;                 // Flag indicating if the walk point has been set
    public float walkPointRange;       // Maximum range for random walk point selection

    // Attacking variables
    public float timeBetweenAttacks;   // Time delay between attacks
    bool alreadyAttacked;              // Flag indicating if the enemy has already attacked
    public GameObject projectile;      // The projectile game object to shoot at the player

    // State detection variables
    public float sightRange, attackRange;          // Ranges for detecting sight and attack states
    public bool playerInSightRange, playerInAttackRange; // Flags indicating whether the player is in sight or attack range

    // Called when the script instance is being loaded
    private void Awake()
    {
        // Find the player object in the scene and get its transform
        player = GameObject.Find("Player").transform;

        // Get the NavMeshAgent component attached to this enemy game object
        agent = GetComponent<NavMeshAgent>();
    }

    // Called once per frame
    private void Update()
    {
        // Check if the player is within the defined sight and attack ranges
        playerInSightRange = Physics.CheckSphere(transform.position, sightRange, whatIsPlayer);
        playerInAttackRange = Physics.CheckSphere(transform.position, attackRange, whatIsPlayer);

        // Determine the behavior based on the player's position relative to the enemy
        if (!playerInSightRange && !playerInAttackRange) Patroling(); // Patrol if the player isn't seen or in range
        if (playerInSightRange && !playerInAttackRange) ChasePlayer(); // Chase if the player is seen but not in attack range
        if (playerInAttackRange && playerInSightRange) AttackPlayer(); // Attack if the player is within range and seen
    }

    // Function that handles the patrol behavior
    private void Patroling()
    {
        // Search for a new walk point if not already set
        if (!walkPointSet) SearchWalkPoint();

        // Move to the walk point if it is set
        if (walkPointSet)
            agent.SetDestination(walkPoint);

        // Calculate the distance to the current walk point
        Vector3 distanceToWalkPoint = transform.position - walkPoint;

        // Check if the enemy has reached the walk point and reset the flag
        if (distanceToWalkPoint.magnitude < 1f)
            walkPointSet = false;
    }

    // Function to find a random point to patrol to within the set range
    private void SearchWalkPoint()
    {
        // Generate random coordinates for the walk point within the patrol range
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);

        // Set the walk point based on the enemy's current position
        walkPoint = new Vector3(transform.position.x + randomX, transform.position.y, transform.position.z + randomZ);

        // Ensure the walk point is on the ground by performing a raycast
        if (Physics.Raycast(walkPoint, -transform.up, 2f, whatIsGround))
            walkPointSet = true;
    }

    // Function that makes the enemy chase the player
    private void ChasePlayer()
    {
        // Set the destination to the player's position
        agent.SetDestination(player.position);
    }

    // Function that manages the attack behavior
    private void AttackPlayer()
    {
        // Prevent movement while attacking
        agent.SetDestination(transform.position);

        // Face the enemy toward the player
        transform.LookAt(player);

        // Only attack if an attack isn't already in progress
        if (!alreadyAttacked)
        {
            // Instantiate the projectile at the designated spawn point with the correct rotation
            Rigidbody rb = Instantiate(projectile, projectileSpawnPoint.position, projectileSpawnPoint.rotation).GetComponent<Rigidbody>();

            // Apply forward and upward force to propel the projectile in a specific direction
            rb.AddForce(transform.forward * 32f, ForceMode.Impulse);
            rb.AddForce(transform.up * -5f, ForceMode.Impulse);

            // Mark the attack as completed and set a delay before the next attack
            alreadyAttacked = true;
            Invoke(nameof(ResetAttack), timeBetweenAttacks);
        }
    }

    // Function to reset the attack cooldown
    private void ResetAttack()
    {
        alreadyAttacked = false;
    }

}
