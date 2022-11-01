using NUnit.Framework;

namespace unittest
{
    public class Tests
    {
        [SetUp]
        public void Setup()
        {
        }   

        public bool equal(int a, int b )
        {
            if(a == b)
            {
                return true;
            }
            else return  false;
        
        }
         public bool even(int num)
        {
            if (num % 2 ==0)
            {
                return true;
            }
            else return false;
        }

        [Test]
        public void Test1()
        {
            Assert.Pass();
        }  

        [Test]
        public void equal_test()
        {
            var result = equal(2,2);
            Assert.IsTrue(result,"input is equal");
        }

         [Test]
        public void even_test()
        {
            var result = even(2);
            Assert.IsTrue(result,"odd number");
        }

    }
}