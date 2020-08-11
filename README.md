# Private-Share
The various data and privacy regulations introduced around the globe, require data to be stored in a secure and privacy-preserving fashion. Non-compliance with these regulations come with major consequences. This has led to the formation of huge data silos within organizations leading to difficult data analysis along with an increased risk of a data breach. Isolating data also prevents collaborative research. To address this, we present Private-Share, a framework that would enable the secure sharing of large scale data. In order to achieve this goal, Private-Share leverages the recent advances in blockchain technology specifically the InterPlanetary File System and Ethereum.

## Setup
### IPFS Setup.
    bash ipfs_cluster_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --hosts <HOST_LIST>
   
### Ethereum Setup.  
     bash ethereum_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --host <HOST>

### Web App Deployment
    bash webapp_setup.sh --user <USER_NAME> --key <PPRIVATE_KEY> --host <HOST>
    
## Demo
Video demonstration of the setup and functionality could be found at the below links.
1. [Webapp Setup](https://www.youtube.com/watch?v=wYj7hKg-sDw)
2. [Ethereum Network Setup](https://www.youtube.com/watch?v=BkF38oYGjN4&t=16s)
3. [IFPS Network Setup](https://www.youtube.com/watch?v=5zvhEJMp_To)
4. [To Create an Account](https://www.youtube.com/watch?v=pSXPiq8D6q4)
5. [Upload a File](https://www.youtube.com/watch?v=m_Y0Eo2gxkM)
6. [Download the File](https://www.youtube.com/watch?v=hs5MoG4WcnY)

## References
[1] H. Jin, Y. Luo, P. Li, and J. Mathew, “A review of secure and privacy- preserving medical data sharing,” IEEE Access, vol. 7, pp. 61656– 61 669, 2019.

[2] J. Liu, X. Li, L. Ye, H. Zhang, X. Du, and M. Guizani, “Bpds: A blockchain based privacy-preserving data sharing for electronic medical records,” in 2018 IEEE Global Communications Conference (GLOBECOM), 2018, pp. 1–6.

[3] [Ethereum Platform.](https://github.com/ethereum/go-ethereum/releases)

[4] [IPFS](https://docs.ipfs.io)

[5] [libfuse](https://github.com/libfuse/libfuse)
