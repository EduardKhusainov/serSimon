using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class FireBall : MonoBehaviour
{
    [SerializeField] private GameObject fireBallBullet;
    private CharacterController characterController;
    Vector3 moveDirection = Vector3.zero;
    public bool isJumped;
    public bool isSided;
    public bool canMove;
    public float coefficientLeftMovement;
    public float lookSpeed;
    public float jumpSpeed;
    public float gravity = 20.0f;
    public float runningSpeed;
    public float walkingSpeed;
    public GameObject shootPos;

    
    private void Start() 
    {
        characterController = GetComponent<CharacterController>();
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;     
    }
    void Update()
    {
        Pause();
        if(Input.GetMouseButtonDown(0))
        {
           var bullet =  Instantiate(fireBallBullet, shootPos.transform.position, transform.rotation);
           Destroy(bullet, 5f);
        }
        transform.rotation *= Quaternion.Euler(0, Input.GetAxis("Mouse X") * lookSpeed, 0);
        if(canMove)
        {
            Move();
            WalkingToSide();
        }
    }

    public void Move()
    {
        
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);
        
        bool isRunning = Input.GetKey(KeyCode.LeftShift);
        float curSpeedX = canMove ? (isRunning ? runningSpeed : walkingSpeed) * Input.GetAxis("Vertical") : 0;
        float curSpeedY = canMove ? (isRunning ? runningSpeed : walkingSpeed) * Input.GetAxis("Horizontal") : 0;
        float movementDirectionY = moveDirection.y;
        if(Input.GetAxis("Vertical") > 0 || Input.GetAxis("Vertical") < 0)
        {
            isSided = false;
        } 
        if(isSided)
        {
           moveDirection = (right * curSpeedY)/coefficientLeftMovement;
        }
        else
        {
            moveDirection = (forward * curSpeedX);
        }

        if (Input.GetButtonDown("Jump") && characterController.isGrounded)
        {
            moveDirection.y = jumpSpeed;
        }
        else
        {
            moveDirection.y = movementDirectionY;
        }

        if (!characterController.isGrounded)
        {
            moveDirection.y -= gravity * Time.deltaTime;
        }
        characterController.Move(moveDirection * Time.deltaTime);
    }

     public void WalkingToSide()
    {
         if(Input.GetAxis("Horizontal") < 0 && characterController.isGrounded)
         {
            isSided = true;
         }
          if(Input.GetAxis("Horizontal") > 0 && characterController.isGrounded)
         {
            isSided = true;
         }
    }
      public void Pause()
    {
         if(Input.GetKeyDown(KeyCode.Q))
        {
            canMove = false;
            Time.timeScale = 0;
        }
        if(Input.GetKeyDown(KeyCode.E))
        {
            Time.timeScale = 1;
            canMove = true;
        }
    }
}